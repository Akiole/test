include $(ROOTDIR)/rules.mk

PKG_NAME:=libnghttp2
PKG_VERSION:=1.67.1
SRC_DIR:=./nghttp2-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-examples \
	--without-mruby \
	--without-neverbleed \
	--without-libxml2 \
	--without-zlib \
	--without-openssl \
	--without-libev \
	--without-jansson \
	--without-jemalloc \
	--without-systemd

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libnghttp2.so* $(ROMFSDIR)/lib/
