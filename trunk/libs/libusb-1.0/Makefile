include $(ROOTDIR)/rules.mk

PKG_NAME:=libusb-1.0
PKG_VERSION:=1.0.30
SRC_DIR:=./libusb-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-log \
	--disable-udev \
	--disable-examples-build \
	--disable-tests-build \
	--disable-dependency-tracking

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libusb-1.0.so* $(ROMFSDIR)/lib/