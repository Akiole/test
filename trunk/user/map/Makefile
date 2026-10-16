include $(ROOTDIR)/rules.mk

PKG_NAME:=map

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/map_controller $(ROMFSDIR)/sbin/map_controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/map_agent $(ROMFSDIR)/sbin/map_agent
