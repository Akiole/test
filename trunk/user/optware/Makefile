include $(ROOTDIR)/rules.mk

PKG_NAME:=optware
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
	mkdir -p $(ROMFSDIR)/etc_ro/opt
	$(ROMFSINST) /etc_ro/ipkg.conf
	$(ROMFSINST) -p +x /usr/bin/ipkg.sh
	$(ROMFSINST) -p +x /usr/bin/opkg.sh
	$(ROMFSINST) -p +x /usr/bin/opt-start.sh
	$(ROMFSINST) -p +x /usr/bin/opt-mount.sh
	$(ROMFSINST) -p +x /usr/bin/opt-umount.sh
	$(ROMFSINST) -p +x /usr/bin/opt-ipkg-upd.sh
	$(ROMFSINST) -p +x /usr/bin/opt-opkg-upd.sh
	$(ROMFSINST) -p +x /usr/bin/opt-mkswap
