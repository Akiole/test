include $(ROOTDIR)/rules.mk

PKG_NAME:=parted
PKG_VERSION:=3.7
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_VARS += \
	LIBS="-liconv"

CONFIGURE_ARGS += \
	--without-readline \
	--disable-shared \
	--disable-static \
	--disable-device-mapper \
	--disable-nls \
	--disable-debug

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/parted/parted $(ROMFSDIR)/sbin/parted
