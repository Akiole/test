include $(ROOTDIR)/rules.mk

PKG_NAME:=naiveproxy
PKG_VERSION:=150.0.7871.63-1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Configure
endef

define Build/Compile
	$(TARGET_CROSS)strip $(PKG_BUILD_DIR)/naive
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/naive $(ROMFSDIR)/usr/bin/naive
