include $(ROOTDIR)/rules.mk

PKG_NAME:=httpd

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += \
	$(if $(STORAGE_ENABLED),-I$(STAGING_DIR)/include/libdisk,)

# musl provides fopencookie natively; uClibc does not. Tell the compat
# header to skip its definitions when building with musl.
ifneq ($(findstring musl,$(CROSS_COMPILE)),)
TARGET_CFLAGS += -DHAVE_FOPENCOOKIE
endif

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/httpd $(ROMFSDIR)/usr/sbin/httpd
ifeq ($(CONFIG_FIRMWARE_INCLUDE_HTTPS),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./https-cert.sh $(ROMFSDIR)/usr/bin/https-cert.sh
endif
