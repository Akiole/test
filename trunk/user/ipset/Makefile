include $(ROOTDIR)/rules.mk

PKG_NAME:=ipset
PKG_VERSION:=7.24
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://ipset.netfilter.org
PKG_HASH:=fbe3424dff222c1cb5e5c34d38b64524b2217ce80226c14fdcbb13b29ea36112
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--with-kmod=yes \
	--with-kbuild=$(ROOTDIR)/$(CONFIG_LINUXDIR)

EXTRA_LDFLAGS += -Wl,-rpath-link,$(STAGEDIR)/lib

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) LDFLAGS= modules
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ipset $(ROMFSDIR)/sbin/ipset
