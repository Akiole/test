include $(ROOTDIR)/rules.mk

PKG_NAME:=wireguard-tools
PKG_VERSION:=1.0.20260223
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
