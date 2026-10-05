include $(ROOTDIR)/rules.mk

PKG_NAME:=iptables
PKG_VERSION:=1.8.13

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.netfilter.org/pub/iptables/
PKG_HASH:=1afcd33da9e8f913ace6a2126788162e207e26f5d5e29c6573c0e581ffc58b99

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-static \
	--disable-shared \
	--disable-nftables \
	--disable-connlabel \
	--with-xtlibdir=/usr/lib/xtables \
	--with-kernel=$(ROOTDIR)/$(LINUXDIR) \
	--with-xt-lock-name="/var/lock/xtables.lock"

# Build libxtables with -fPIC so it can be linked into shared objects (e.g. iproute2 m_xt.so)
TARGET_CFLAGS += -fPIC

# Install netfilter headers to stage/include so downstream packages
# (miniupnpd etc.) use our patched versions instead of toolchain sysroot
define Build/Install
	$(call Build/Install/Default)
	$(INSTALL_DIR) $(STAGING_DIR)/include/linux/netfilter
	$(CP) $(PKG_BUILD_DIR)/include/linux/netfilter/*.h $(STAGING_DIR)/include/linux/netfilter/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iptables/xtables-legacy-multi $(ROMFSDIR)/bin/xtables-multi
	for link in iptables iptables-restore iptables-save \
		$(if $(CONFIG_IPV6),ip6tables ip6tables-restore ip6tables-save); do \
			$(LN) xtables-multi $(ROMFSDIR)/bin/$$link; \
	done
