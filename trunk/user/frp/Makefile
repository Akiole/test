include $(ROOTDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.71.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	@echo "Prebuilt binary package"
endef

define Build/Compile
	@echo "frp uses prebuilt binaries"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FRPC),y)
	$(INSTALL_BIN) ./frpc $(ROMFSDIR)/usr/bin/frpc
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FRPS),y)
	$(INSTALL_BIN) ./frps $(ROMFSDIR)/usr/bin/frps
endif
	$(INSTALL_BIN) ./frp.sh $(ROMFSDIR)/usr/bin/frp.sh
	$(ROMFSINST) /etc_ro/frp_script.sh
