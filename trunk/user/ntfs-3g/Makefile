include $(ROOTDIR)/rules.mk

PKG_NAME:=ntfs-3g
PKG_VERSION:=2026.9.28
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tuxera/ntfs-3g/tar.gz/$(PKG_VERSION)?
PKG_HASH:=8a75293f07bf40df5701d296de32a4cb0e46d6ae135abb4f41b438df9868a390

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

# NTFS on-disk structures are packed; taking addresses of members is
# intentional and safe on MIPS. Suppress the resulting warnings.
TARGET_CFLAGS += -Wno-address-of-packed-member

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

define Build/Prepare
	$(call Build/Prepare/Default)
	# autoreconf may not create all auxiliary files; run automake to add them
	(cd $(PKG_BUILD_DIR); automake --add-missing --copy 2>/dev/null || true)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_ENABLE_FUSE),y)
ifneq ($(CONFIG_FIRMWARE_ENABLE_UFSD),y)
	$(ROMFSINST) $(PKG_BUILD_DIR)/src/ntfs-3g /sbin/ntfs-3g
endif
endif
