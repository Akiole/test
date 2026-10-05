include $(ROOTDIR)/rules.mk

PKG_NAME:=libxml2
PKG_VERSION:=2.15.4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/GNOME/libxml2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=bb01bd9ac9a7403f9706816fd6d3e7888041d32b0211075feb20e755d2a9f29d

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--without-catalog \
	--without-debug \
	--without-http \
	--without-python \
	--without-readline \
	--without-iconv \
	--with-zlib=$(STAGING_DIR) \
	--with-threads \
	--with-reader \
	--with-writer \
	--with-xpath \
	--disable-dependency-tracking \
	--disable-maintainer-mode

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libxml2.so* $(ROMFSDIR)/lib/
