include $(ROOTDIR)/rules.mk

PKG_NAME:=scutclient
PKG_VERSION:=8c81f5d8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/scutclient/scutclient/tar.gz/$(PKG_VERSION)?
PKG_HASH:=b9cb2f376d8d3b7e7bccbe0bb2ddc86f53d8656cfef3a23e03ad4c6b4f35108b

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./scripts/scutclient.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/scutclient_watchcat.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scutclient $(ROMFSDIR)/usr/bin/bin_scutclient
