include $(ROOTDIR)/rules.mk

PKG_NAME:=libcap-ng
PKG_VERSION:=0.8.5
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--without-python3

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcap-ng.so* $(ROMFSDIR)/lib/