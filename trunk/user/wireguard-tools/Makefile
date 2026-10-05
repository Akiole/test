include $(ROOTDIR)/rules.mk

PKG_NAME:=wireguard-tools
PKG_VERSION:=1.0.20260223
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/WireGuard/wireguard-tools/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=859f8af03702db5e5c43f8ece77f5ebef40a2f4627c3e03997a031d4940ea9bc

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)/src/uapi/linux -DRUNSTATEDIR='\"/var/run\"'" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		PLATFORM=linux \
		WITH_BASHCOMPLETION=no \
		WITH_WGQUICK=yes \
		WITH_SYSTEMDUNITS=no \
		all
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wg $(ROMFSDIR)/usr/bin/wg
