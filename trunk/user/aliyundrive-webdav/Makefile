# aliyundrive-webdav - prebuilt mipsel binary for Padavan

include $(ROOTDIR)/rules.mk

PKG_NAME:=aliyundrive-webdav
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	@echo "Prebuilt binary package"
endef

define Build/Compile
	@echo "Nothing to compile"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./aliyundrive-webdav $(ROMFSDIR)/usr/bin/aliyundrive-webdav
	$(INSTALL_BIN) ./aliyundrive-webdav.sh $(ROMFSDIR)/usr/bin/aliyundrive-webdav.sh
