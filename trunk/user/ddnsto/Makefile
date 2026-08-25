# ddnsto - official multi-arch binary package, using mipsel build

include $(ROOTDIR)/rules.mk

PKG_NAME:=ddnsto
PKG_VERSION:=4.0.7

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
	$(INSTALL_BIN) ./ddnsto.mipsel $(ROMFSDIR)/usr/bin/ddnsto
	$(INSTALL_BIN) ./ddnsto.sh $(ROMFSDIR)/usr/bin/ddnsto.sh
