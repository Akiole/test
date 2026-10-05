include $(ROOTDIR)/rules.mk

PKG_NAME:=scripts

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	$(CP) ./files $(PKG_BUILD_DIR)/
	mkdir -p $(PKG_BUILD_DIR)/files/usr/share/terminfo
	tar -xzf ./terminfo.tar.gz -C $(PKG_BUILD_DIR)/files/usr/share
endef


define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifneq ($(IS_DARWIN),)
	FAKED_MODE=1 ./makedevlinks $(ROMFSDIR)
else
	fakeroot ./makedevlinks $(ROMFSDIR)
endif
	$(CP) $(PKG_BUILD_DIR)/files/* $(ROMFSDIR)/
ifneq ($(STORAGE_ENABLED),y)
	rm -f $(ROMFSDIR)/sbin/automount.sh
endif
ifndef CONFIG_BLK_DEV_SD
	rm -f $(ROMFSDIR)/sbin/hddtune.sh
	rm -f $(ROMFSDIR)/sbin/spindown.sh
endif
ifndef CONFIG_MTD_UBI
	rm -f $(ROMFSDIR)/sbin/rwfs2ubi.sh
endif
