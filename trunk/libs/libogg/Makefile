include $(ROOTDIR)/rules.mk

PKG_NAME:=libogg
PKG_VERSION:=1.3.6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xiph/ogg/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=95b643da661155d79db9de2fca55daed3a8d491039829def246aacb3d9201c81
PKG_BUILD_DIR:=$(BUILD_DIR)/ogg-1.3.6

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-debug \
	--disable-docs

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libogg.so* $(ROMFSDIR)/lib/