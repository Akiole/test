# wing - prebuilt mipsel binary with gfwlist for Padavan

include $(ROOTDIR)/rules.mk

PKG_NAME:=wing

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	@echo "Nothing to compile"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/gfwlist.txt $(ROMFSDIR)/etc_ro/gfwlist.txt
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wing $(ROMFSDIR)/usr/bin/wing
