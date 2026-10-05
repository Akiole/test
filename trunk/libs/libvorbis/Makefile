include $(ROOTDIR)/rules.mk

PKG_NAME:=libvorbis
PKG_VERSION:=1.3.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xiph/vorbis/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=270c76933d0934e42c5ee0a54a36280e2d87af1de3cc3e584806357e237afd13
PKG_BUILD_DIR:=$(BUILD_DIR)/vorbis-1.3.7

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-docs \
	--disable-examples \
	--disable-oggtest \
	--with-ogg-prefix=$(STAGING_DIR)/usr

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libvorbis.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libvorbisenc.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libvorbisfile.so* $(ROMFSDIR)/lib/
