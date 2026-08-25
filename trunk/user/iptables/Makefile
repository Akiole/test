# iptables 1.8.7 with Padavan custom extensions (FULLCONENAT/HL/TTL/DSCP-mark etc.)
# Source is bundled locally due to extensive kernel 4.4.x compatibility patches

include $(ROOTDIR)/rules.mk

PKG_NAME:=iptables
PKG_VERSION:=1.8.7
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

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/xtables $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iptables/xtables-legacy-multi $(ROMFSDIR)/bin/xtables-multi
	for link in iptables iptables-restore iptables-save \
		$(if $(CONFIG_IPV6),ip6tables ip6tables-restore ip6tables-save); do \
			$(LN) xtables-multi $(ROMFSDIR)/bin/$$link; \
	done
