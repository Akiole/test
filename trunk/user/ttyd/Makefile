include $(ROOTDIR)/rules.mk

PKG_NAME:=ttyd
PKG_VERSION:=1.7.7
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ttyd $(ROMFSDIR)/usr/bin/ttyd
	$(INSTALL_BIN) ./ttyd.sh $(ROMFSDIR)/usr/bin/ttyd.sh
