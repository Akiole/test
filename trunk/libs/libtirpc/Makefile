include $(ROOTDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.3.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-gssapi \
	--disable-debug \
	--disable-dependency-tracking

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libtirpc.so* $(ROMFSDIR)/lib/
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/netconfig $(ROMFSDIR)/etc_ro/netconfig