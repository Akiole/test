include $(ROOTDIR)/rules.mk

PKG_NAME:=libiconv
PKG_VERSION:=1.18
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--enable-relocatable \
	--disable-nls \
	--disable-extra-encodings

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libiconv.so* $(ROMFSDIR)/lib/