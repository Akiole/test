include $(ROOTDIR)/rules.mk

PKG_NAME:=libogg
PKG_VERSION:=1.3.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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