include $(ROOTDIR)/rules.mk

PKG_NAME:=adbyby
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	@echo "Data package"
endef

define Build/Compile
	@echo "Nothing to compile"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) /etc_ro/adbyby.tar.gz
	$(ROMFSINST) /etc_ro/adbyby_rules.sh
	$(ROMFSINST) /etc_ro/adbyby_adblack.sh
	$(ROMFSINST) /etc_ro/adbyby_adesc.sh
	$(ROMFSINST) /etc_ro/adbyby_adhost.sh
	$(ROMFSINST) /etc_ro/adbyby_host.sh
	$(ROMFSINST) /etc_ro/adbyby_blockip.sh
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./adbyby.sh $(ROMFSDIR)/usr/bin/adbyby.sh
