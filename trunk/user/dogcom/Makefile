include $(ROOTDIR)/rules.mk

PKG_NAME:=dogcom
PKG_VERSION:=1.6.2-pdv
PKG_SOURCE:=dogcom-1.6.2-pdv.tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/mchome/dogcom/tar.gz/v1.6.2?
PKG_HASH:=4feac74138cab483e3852cb5cb435160795440ffce4c7f715fc9fd546846a66d
PKG_BUILD_DIR:=$(BUILD_DIR)/dogcom-1.6.2

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) CC="$(TARGET_CC)"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dogcom $(ROMFSDIR)/usr/bin/dogcom
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/dogcom
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/sample-p.conf $(ROMFSDIR)/etc_ro/dogcom/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/sample-d.conf $(ROMFSDIR)/etc_ro/dogcom/
