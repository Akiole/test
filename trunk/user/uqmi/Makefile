include $(ROOTDIR)/rules.mk

PKG_NAME:=uqmi
PKG_VERSION:=20261011
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openwrt/uqmi/tar.gz/refs/heads/master?
PKG_HASH:=27e8a8fdbce6ac552dd2c693dfb64055db741d5c098caf9fdd90c3e8f89ff45d
PKG_BUILD_DIR:=$(BUILD_DIR)/uqmi-master

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_UQMID=OFF \
	-DBUILD_STATIC=OFF

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uqmi/uqmi $(ROMFSDIR)/bin/uqmi
