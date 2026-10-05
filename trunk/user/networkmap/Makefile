include $(ROOTDIR)/rules.mk

PKG_NAME:=networkmap

include $(INCLUDE_DIR)/package.mk


$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/networkmap $(ROMFSDIR)/usr/sbin/networkmap
