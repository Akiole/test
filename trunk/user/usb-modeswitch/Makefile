include $(ROOTDIR)/rules.mk

PKG_NAME:=usb-modeswitch
PKG_VERSION:=2.6.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/include/libusb-1.0

define Build/Prepare
	$(call Build/Prepare/Default)
	# Download usb-modeswitch-data (not included in main source)
	curl -sL https://www.draisberghof.de/usb_modeswitch/usb-modeswitch-data-20251207.tar.bz2 | tar xj -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/usb_modeswitch $(PKG_BUILD_DIR)/usb_modeswitch.c -lusb-1.0 $(TARGET_LDFLAGS)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/usb_modeswitch /bin/usb_modeswitch
	mkdir -p $(ROMFSDIR)/etc_ro
	$(CP) $(PKG_BUILD_DIR)/usb_modeswitch.d $(ROMFSDIR)/etc_ro
