include $(ROOTDIR)/rules.mk

PKG_NAME:=u2ec

include $(INCLUDE_DIR)/package.mk


$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/u2ec $(ROMFSDIR)/usr/sbin/u2ec
