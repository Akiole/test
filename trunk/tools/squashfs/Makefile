include $(ROOTDIR)/rules.mk

PKG_NAME := squashfs-tools
PKG_VERSION := 4.7.5
SRC_DIR := ./$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL := 1

include $(INCLUDE_DIR)/package.mk

# macOS stat struct uses st_atimespec instead of st_atim
DARWIN_CFLAGS := $(if $(filter Darwin,$(shell uname)),\
	-Dst_atim=st_atimespec -Dst_mtim=st_mtimespec -Dst_ctim=st_ctimespec \
	-I$(shell brew --prefix)/include -L$(shell brew --prefix)/lib,)

define Build/Compile
	@echo "==> Compiling $(PKG_NAME) (xz only)..."
	+$(MAKE) -C $(PKG_BUILD_DIR) \
		EXTRA_CFLAGS="$(DARWIN_CFLAGS)" \
		COMP_DEFAULT=xz \
		XZ_SUPPORT=1 \
		GZIP_SUPPORT=0 \
		LZO_SUPPORT=0 \
		LZ4_SUPPORT=0 \
		ZSTD_SUPPORT=0 \
		XATTR_SUPPORT=0 \
		XATTR_OS_SUPPORT=0
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mksquashfs $(ROOTDIR)/tools/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unsquashfs $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,squashfs-tools))
