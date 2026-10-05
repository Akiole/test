include $(ROOTDIR)/rules.mk

PKG_NAME:=mtd-utils
PKG_VERSION:=2.3.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://infraroot.at/pub/mtd/
PKG_HASH:=03d9dc58ad10ea3549d9528f6b17a44d8944e18e96c0f31474f9f977078b83dc

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
