include $(ROOTDIR)/rules.mk

PKG_NAME := lzma
PKG_VERSION := 2602
SRC_DIR := ./$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL := 1

include $(INCLUDE_DIR)/package.mk

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
