# iptables 1.8.13 with Padavan custom extensions (FULLCONENAT/HL/TTL/DSCP-mark etc.)
# Source is bundled locally due to extensive kernel 4.4.x compatibility patches

include $(ROOTDIR)/rules.mk

PKG_NAME:=iptables
PKG_VERSION:=1.8.13
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-nftables \
	--disable-connlabel \
	--with-xtlibdir=/usr/lib/xtables \
	--with-kernel=$(ROOTDIR)/$(LINUXDIR) \
	--with-xt-lock-name="/var/lock/xtables.lock"

# 6.6 UAPI headers (include/uapi/linux/swab.h via linux/ip.h) use the
# kernel-internal __attribute_const__ macro, undefined for userspace.
# Define it empty, as upstream userspace consumers of UAPI do.
TARGET_CFLAGS += -D__attribute_const__=

# Disable --no-undefined to allow runtime symbol resolution for shared modules
define Build/Configure
	$(call Build/Configure/Default)
	@for f in extensions/GNUmakefile libiptc/GNUmakefile; do \
		if [ -f $(PKG_BUILD_DIR)/$$f ]; then \
			$(SED) 's/AM_LDFLAGS\s*=\s*-Wl,--no-undefined/AM_LDFLAGS =/' $(PKG_BUILD_DIR)/$$f; \
		fi; \
	done
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/xtables $(ROMFSDIR)/bin $(ROMFSDIR)/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iptables/.libs/xtables-legacy-multi $(ROMFSDIR)/bin/xtables-multi
	# Install shared libraries
	$(CP) $(PKG_BUILD_DIR)/libxtables/.libs/libxtables.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_BUILD_DIR)/libiptc/.libs/libip4tc.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_BUILD_DIR)/libiptc/.libs/libip6tc.so* $(ROMFSDIR)/lib/
	# Install xtables plugins (built as shared modules in extensions/)
	$(CP) $(PKG_BUILD_DIR)/extensions/*.so $(ROMFSDIR)/usr/lib/xtables/
	for link in iptables iptables-restore iptables-save \
		$(if $(CONFIG_IPV6),ip6tables ip6tables-restore ip6tables-save); do \
			$(LN) xtables-multi $(ROMFSDIR)/bin/$$link; \
	done
