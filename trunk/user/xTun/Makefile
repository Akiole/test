include $(ROOTDIR)/rules.mk

PKG_NAME:=xTun
PKG_VERSION:=0.6.5
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) HOST=$(HOST_TARGET)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(STRIP) $(PKG_BUILD_DIR)/xTun
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xTun $(ROMFSDIR)/usr/bin/xTun
	$(INSTALL_BIN) ./xTun.sh $(ROMFSDIR)/usr/bin/xTun.sh
