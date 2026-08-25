include $(ROOTDIR)/rules.mk

PKG_NAME:=igmpproxy
PKG_VERSION:=0.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/igmpproxy $(ROMFSDIR)/bin/igmpproxy
