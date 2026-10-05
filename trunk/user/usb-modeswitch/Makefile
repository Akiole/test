include $(ROOTDIR)/rules.mk

PKG_NAME:=usb-modeswitch
PKG_VERSION:=2.6.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://www.draisberghof.de/usb_modeswitch/
PKG_HASH:=f7abd337784a9d1bd39cb8a587518aff6f2a43d916145eafd80b1b8b7146db66

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/include/libusb-1.0

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(CURDIR)/usb_modeswitch.d $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/usb_modeswitch $(PKG_BUILD_DIR)/usb_modeswitch.c -lusb-1.0 $(TARGET_LDFLAGS)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/usb_modeswitch /bin/usb_modeswitch
	mkdir -p $(ROMFSDIR)/etc_ro
	$(CP) $(PKG_BUILD_DIR)/usb_modeswitch.d $(ROMFSDIR)/etc_ro
