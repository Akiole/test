include $(ROOTDIR)/rules.mk

PKG_NAME:=rtp2httpd
PKG_VERSION:=3.17.2
PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/stackia/rtp2httpd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ce866091321a0d69dff7e8f7dda5d68be94e901659ed7d2ff4896029c8200ee6

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
