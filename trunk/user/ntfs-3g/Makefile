include $(ROOTDIR)/rules.mk

PKG_NAME:=ntfs-3g
PKG_VERSION:=2026.7.7
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--prefix=/usr \
	--enable-shared=no \
	--enable-static=no \
	--disable-mtab \
	--disable-debug \
	--disable-library \
	--disable-ldconfig \
	--disable-mount-helper \
	--with-fuse=internal

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_ENABLE_FUSE),y)
ifneq ($(CONFIG_FIRMWARE_ENABLE_UFSD),y)
	$(ROMFSINST) $(PKG_BUILD_DIR)/src/ntfs-3g /sbin/ntfs-3g
endif
endif
