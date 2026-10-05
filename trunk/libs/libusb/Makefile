include $(ROOTDIR)/rules.mk

PKG_NAME:=libusb
PKG_VERSION:=0.1.9

PKG_SOURCE:=libusb-compat-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libusb/libusb-compat-0.1/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=991250aecf97e36ed013dcff8ed40583fdd55fd9c387036d2eb759792fde2989
PKG_BUILD_DIR:=$(BUILD_DIR)/libusb-compat-0.1-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

DEPENDS:=+libusb-1.0

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-log \
	--disable-debug-log \
	--disable-examples-build

TARGET_CFLAGS += -Wno-format-truncation

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
