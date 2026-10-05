include $(ROOTDIR)/rules.mk

PKG_NAME:=srelay
PKG_VERSION:=0.4.8p3
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gco/srelay/tar.gz/refs/heads/master?
PKG_HASH:=1ecfab2aa0e8b51f087784a242a94d4f81eaaf87625cdf8cb88b7f3a5f1563b8
PKG_BUILD_DIR:=$(BUILD_DIR)/srelay-master

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/srelay $(ROMFSDIR)/usr/bin/srelay
