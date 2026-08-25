include $(ROOTDIR)/rules.mk

PKG_NAME:=librtlsdr
PKG_VERSION:=2.0.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS += \
	-Os \
	-ffunction-sections \
	-fdata-sections \
	-I$(STAGING_DIR)/include/libusb-1.0

TARGET_LDFLAGS += \
	-Wl,--gc-sections \
	-L$(STAGING_DIR)/lib \
	-Wl,-rpath-link=$(STAGING_DIR)/lib

CMAKE_OPTIONS += \
	-DINSTALL_UDEV_RULES=OFF \
	-DDETACH_KERNEL_DRIVER=ON \
	-DENABLE_ZEROCOPY=ON \
	-DWITH_SOAPYSDR=OFF \
	-DWITH_CONVENIENCE_LIB=OFF \
	-DBUILD_TESTING=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_EXAMPLES=OFF \
	-DCMAKE_BUILD_TYPE=Release

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/librtlsdr.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_RTL_SDR),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rtl_fm $(ROMFSDIR)/usr/bin/rtl_fm
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rtl_tcp $(ROMFSDIR)/usr/bin/rtl_tcp
endif
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/librtlsdr.so* $(ROMFSDIR)/lib/
