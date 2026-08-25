include $(ROOTDIR)/rules.mk

PKG_NAME:=libxml2
PKG_VERSION:=2.15.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
