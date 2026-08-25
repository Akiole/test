include $(ROOTDIR)/rules.mk

PKG_NAME:=neofetch
PKG_VERSION:=master
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neofetch $(ROMFSDIR)/usr/bin/neofetch
