include $(ROOTDIR)/rules.mk

PKG_NAME:=e2fsprogs
PKG_VERSION:=1.47.4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git/snapshot/
PKG_HASH:=9f82eaa7002673291629077b80ee005cadfcd49854907a22007fed70b0ef596e

include $(INCLUDE_DIR)/package.mk

ifeq ($(findstring musl,$(TARGET_CROSS)),musl)
  CONFIGURE_VARS += ac_cv_func_lseek64=yes
endif
CONFIGURE_ARGS += \
	--prefix= \
	--disable-bmap-stats \
	--disable-debugfs \
	--disable-testio-debug \
	--disable-fuse2fs \
	--disable-gcov \
	--disable-hardening \
	--disable-imager \
	--disable-resizer \
	--disable-e2initrd-helper \
	--disable-uuidd \
	--disable-mmp \
	--disable-tdb \
	--disable-rpath \
	--disable-nls \
	--disable-static \
	--enable-shared \
	--disable-tls \
	--enable-symlink-build \
	--enable-verbose-makecmds \
	--enable-elf-shlibs \
	--enable-defrag

# link with the compiler driver: e2fsprogs invokes $(LD) directly and the
# raw linker does not understand -Wl, driver flags

MAKE_FLAGS += LD="$(TARGET_CC)"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/e2fsck/e2fsck /sbin/e2fsck
	$(ROMFSINST) $(PKG_BUILD_DIR)/misc/badblocks /sbin/badblocks
	$(ROMFSINST) $(PKG_BUILD_DIR)/misc/e2undo /sbin/e2undo
	$(ROMFSINST) $(PKG_BUILD_DIR)/misc/mke2fs /sbin/mke2fs
	$(ROMFSINST) $(PKG_BUILD_DIR)/misc/tune2fs /sbin/tune2fs
	$(ROMFSINST) $(PKG_BUILD_DIR)/lib/e2p/libe2p.so.2.3 /lib/libe2p.so.2.3
	$(ROMFSINST) $(PKG_BUILD_DIR)/lib/et/libcom_err.so.2.1 /lib/libcom_err.so.2.1
	$(ROMFSINST) $(PKG_BUILD_DIR)/lib/ext2fs/libext2fs.so.2.4 /lib/libext2fs.so.2.4
	$(ROMFSINST) -s libe2p.so.2.3 /lib/libe2p.so.2
	$(ROMFSINST) -s libcom_err.so.2.1 /lib/libcom_err.so.2
	$(ROMFSINST) -s libext2fs.so.2.4 /lib/libext2fs.so.2
	$(ROMFSINST) /etc_ro/e2fsck.conf
ifeq ($(CONFIG_FIRMWARE_ENABLE_EXT2),y)
	$(ROMFSINST) -s mke2fs /sbin/mkfs.ext2
	$(ROMFSINST) -s e2fsck /sbin/fsck.ext2
endif
ifeq ($(CONFIG_FIRMWARE_ENABLE_EXT3),y)
	$(ROMFSINST) -s mke2fs /sbin/mkfs.ext3
	$(ROMFSINST) -s e2fsck /sbin/fsck.ext3
endif
ifeq ($(CONFIG_FIRMWARE_ENABLE_EXT4),y)
	$(ROMFSINST) $(PKG_BUILD_DIR)/misc/e4defrag /sbin/e4defrag
	$(ROMFSINST) -s mke2fs /sbin/mkfs.ext4
	$(ROMFSINST) -s e2fsck /sbin/fsck.ext4
endif
