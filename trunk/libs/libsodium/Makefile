include $(ROOTDIR)/rules.mk

PKG_NAME:=libsodium
PKG_VERSION:=1.0.22
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-ssp \
	--disable-dependency-tracking \
	--disable-valgrind

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libsodium.so* $(ROMFSDIR)/lib/
