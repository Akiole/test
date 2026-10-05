include $(ROOTDIR)/rules.mk

PKG_NAME := lzma
PKG_VERSION := 2604
# LZMA SDK 26.04 is officially distributed as a .7z archive.
# unpack.mk cannot handle .7z, so Build/Prepare extracts it with host 7z.
PKG_SOURCE := lzma$(PKG_VERSION).7z
PKG_SOURCE_URL := https://www.7-zip.org/a/
PKG_HASH := bd98058d0e12c5da970dd4e5e1d8fa24f2d704914d96e69c28f92ed45421a439

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1

# Locate host 7z tool (p7zip or 7-Zip); command -v is more portable than which
HOST_7Z := $(shell { command -v 7z || command -v 7za || command -v 7zr; } 2>/dev/null)

define Build/Prepare
	@echo "==> Preparing $(PKG_NAME) (extracting .7z with $(HOST_7Z))..."
	@if [ -z "$(HOST_7Z)" ]; then \
		echo "ERROR: 7z/7za/7zr not found in PATH. Install p7zip first."; \
		exit 1; \
	fi
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(HOST_7Z) x -y $(DL_DIR)/$(PKG_SOURCE) -o$(PKG_BUILD_DIR) > /dev/null
	touch $(PKG_BUILD_DIR)/.prepared
endef

define Build/Compile
	@echo "==> Compiling $(PKG_NAME) (host tool)..."
	# LZMA SDK console tool — must use host compiler, NOT cross-compiler
	+$(MAKE) -C $(PKG_BUILD_DIR)/CPP/7zip/Bundles/LzmaCon -f makefile.gcc
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/CPP/7zip/Bundles/LzmaCon/_o/lzma $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,lzma))
