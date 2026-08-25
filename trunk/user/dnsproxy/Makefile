include $(ROOTDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=1.1.1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dnsproxy $(ROMFSDIR)/usr/bin/dnsproxy
