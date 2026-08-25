include $(ROOTDIR)/rules.mk

PKG_NAME:=libusb
PKG_VERSION:=0.1.12
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-build-docs \
	--enable-debug=no
TARGET_CFLAGS += -Wno-format-truncation

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
