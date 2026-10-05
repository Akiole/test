include $(ROOTDIR)/rules.mk

PKG_NAME:=libusb-1.0
PKG_VERSION:=1.0.30
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libusb/libusb/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2ae28adb0bb9558c86135c4e1c11b320b0805461e207a64a6e520a114094bf07
PKG_BUILD_DIR:=$(BUILD_DIR)/libusb-$(PKG_VERSION)

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