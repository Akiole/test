include $(ROOTDIR)/rules.mk

PKG_NAME:=ipt2socks
PKG_VERSION:=1.1.4
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipt2socks $(ROMFSDIR)/usr/bin/ipt2socks
