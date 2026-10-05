include $(ROOTDIR)/rules.mk

PKG_NAME:=shared
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_BUILD_DIR)/libshared.so $(ROMFSDIR)/lib/
