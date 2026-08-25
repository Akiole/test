include $(ROOTDIR)/rules.mk

PKG_NAME:=dns-forwarder
PKG_VERSION:=1.2.1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dns-forwarder $(ROMFSDIR)/usr/bin/dns-forwarder
	$(INSTALL_BIN) ./dns-forwarder.sh $(ROMFSDIR)/usr/bin/dns-forwarder.sh
