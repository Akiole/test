include $(ROOTDIR)/rules.mk

PKG_NAME:=libvorbis
PKG_VERSION:=1.3.7
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
