include $(ROOTDIR)/rules.mk

PKG_NAME := squashfs-tools
PKG_VERSION := 4.7.5
PKG_SOURCE := $(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://codeload.github.com/plougher/squashfs-tools/tar.gz/refs/tags/$(PKG_VERSION)?
PKG_HASH := 547b7b7f4d2e44bf91b6fc554664850c69563701deab9fd9cd7e21f694c88ea6

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1

# macOS stat struct uses st_atimespec instead of st_atim.
# Reuse IS_DARWIN / HOMEBREW_PREFIX from host-tools.mk (no extra shell calls).
DARWIN_CFLAGS := $(if $(IS_DARWIN),\
	-Dst_atim=st_atimespec -Dst_mtim=st_mtimespec -Dst_ctim=st_ctimespec \
	-I$(HOMEBREW_PREFIX)/include,)
DARWIN_LDFLAGS := $(if $(IS_DARWIN),-L$(HOMEBREW_PREFIX)/lib,)

# Upstream tarball places sources under squashfs-tools/ subdirectory
PKG_BUILD_SUBDIR := squashfs-tools

define Build/Compile
	@echo "==> Compiling $(PKG_NAME)..."
	+$(MAKE) -C $(PKG_BUILD_DIR)/$(PKG_BUILD_SUBDIR) \
		EXTRA_CFLAGS="$(DARWIN_CFLAGS)" \
		EXTRA_LDFLAGS="$(DARWIN_LDFLAGS)" \
		COMP_DEFAULT=xz \
		XZ_SUPPORT=1 \
		GZIP_SUPPORT=1 \
		LZO_SUPPORT=0 \
		LZ4_SUPPORT=0 \
		ZSTD_SUPPORT=0 \
		XATTR_SUPPORT=1 \
		XATTR_OS_SUPPORT=1
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_BUILD_SUBDIR)/mksquashfs $(ROOTDIR)/tools/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_BUILD_SUBDIR)/unsquashfs $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,squashfs-tools))
