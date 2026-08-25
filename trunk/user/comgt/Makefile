include $(ROOTDIR)/rules.mk

PKG_NAME:=comgt
PKG_VERSION:=0.32
SRC_DIR:=./$(PKG_NAME).$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/comgt.c -o $(PKG_BUILD_DIR)/comgt
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/comgt /bin/comgt
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/ppp/3g
	$(CP) $(PKG_BUILD_DIR)/scripts/command $(ROMFSDIR)/etc_ro/ppp/3g/command
	$(CP) $(PKG_BUILD_DIR)/scripts/dump $(ROMFSDIR)/etc_ro/ppp/3g/dump
	$(CP) $(PKG_BUILD_DIR)/scripts/operator $(ROMFSDIR)/etc_ro/ppp/3g/operator
