include $(ROOTDIR)/rules.mk

PKG_NAME:=wireguard
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	@echo "Script package"
endef

define Build/Compile
	@echo "Nothing to compile"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./wireguard.sh $(ROMFSDIR)/usr/bin/wireguard.sh
