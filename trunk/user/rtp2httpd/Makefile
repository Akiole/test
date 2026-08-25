include $(ROOTDIR)/rules.mk

PKG_NAME:=rtp2httpd
PKG_VERSION:=3.11.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

export RELEASE_VERSION=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -DENABLE_AGGRESSIVE_OPT=OFF

# SO_EE_ORIGIN_ZEROCOPY and SO_EE_CODE_ZEROCOPY_COPIED were added in Linux 4.14.

EXTRA_CFLAGS += -DSO_EE_ORIGIN_ZEROCOPY=5 -DSO_EE_CODE_ZEROCOPY_COPIED=1

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(TARGET_CROSS)strip $(PKG_BUILD_DIR)/rtp2httpd
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rtp2httpd $(ROMFSDIR)/usr/bin/rtp2httpd
