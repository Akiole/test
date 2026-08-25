include $(ROOTDIR)/rules.mk

PKG_NAME:=srelay
PKG_VERSION:=0.4.8p3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/srelay $(ROMFSDIR)/usr/bin/srelay
