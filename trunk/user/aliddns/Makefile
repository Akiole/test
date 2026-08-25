include $(ROOTDIR)/rules.mk

PKG_NAME:=aliddns
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
	$(INSTALL_BIN) ./aliddns.sh $(ROMFSDIR)/usr/bin/aliddns.sh
	$(ROMFSINST) /etc_ro/ddns_script.sh
