include $(ROOTDIR)/rules.mk

PKG_NAME:=scutclient
PKG_VERSION:=a589968
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./scripts/scutclient.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/scutclient_watchcat.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scutclient $(ROMFSDIR)/usr/bin/bin_scutclient
