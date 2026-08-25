include $(ROOTDIR)/rules.mk

PKG_NAME:=dogcom
PKG_VERSION:=1.6.2-pdv
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
