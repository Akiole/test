include $(ROOTDIR)/rules.mk

PKG_NAME := mkimage
PKG_VERSION := 1.0
SRC_DIR := ./$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL := 1

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	@echo "==> Compiling $(PKG_NAME)..."
	# U-Boot mkimage with ASUS TAIL header support (host tool)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(PKG_BUILD_DIR)/mkimage \
		$(PKG_BUILD_DIR)/mkimage.c $(PKG_BUILD_DIR)/crc32.c
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mkimage $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,mkimage))
