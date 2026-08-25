include $(ROOTDIR)/rules.mk

PKG_NAME:=libexif
PKG_VERSION:=0.6.26
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-nls \
	--disable-docs \
	--disable-rpath

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libexif.so* $(ROMFSDIR)/lib/