include $(ROOTDIR)/rules.mk

PKG_NAME:=microsocks
PKG_VERSION:=1.0.5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rofl0r/microsocks/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=939d1851a18a4c03f3cc5c92ff7a50eaf045da7814764b4cb9e26921db15abc8

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/microsocks $(ROMFSDIR)/usr/bin/microsocks
