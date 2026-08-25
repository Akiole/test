include $(ROOTDIR)/rules.mk

PKG_NAME:=confuse
PKG_VERSION:=3.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-examples

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libconfuse.so* $(ROMFSDIR)/lib/
