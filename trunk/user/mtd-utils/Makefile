include $(ROOTDIR)/rules.mk

PKG_NAME:=mtd-utils
PKG_VERSION:=2.2.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--prefix= \
	--disable-static \
	--enable-shared \
	--disable-tests \
	--disable-install-tests \
	--without-jffs \
	--without-xattr \
	--without-ubifs \
	--without-zstd \
	--without-crypto \
	--without-lzo

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/ubiattach /sbin/ubiattach
	$(ROMFSINST) $(PKG_BUILD_DIR)/ubidetach /sbin/ubidetach
	$(ROMFSINST) $(PKG_BUILD_DIR)/ubiformat /sbin/ubiformat
	$(ROMFSINST) $(PKG_BUILD_DIR)/ubimkvol /sbin/ubimkvol
	$(ROMFSINST) $(PKG_BUILD_DIR)/ubinfo /sbin/ubinfo
