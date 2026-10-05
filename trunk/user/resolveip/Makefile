include $(ROOTDIR)/rules.mk

PKG_NAME:=resolveip

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I./ -DDBG -DSYSLOG -fvisibility=hidden

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -c $(PKG_BUILD_DIR)/resolveip.c -o $(PKG_BUILD_DIR)/resolveip.o
	$(TARGET_CC) $(TARGET_LDFLAGS) -o $(PKG_BUILD_DIR)/resolveip $(PKG_BUILD_DIR)/resolveip.o
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/resolveip $(ROMFSDIR)/sbin/resolveip
