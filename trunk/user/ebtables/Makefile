include $(ROOTDIR)/rules.mk

PKG_NAME:=ebtables
PKG_VERSION:=2.0.10
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += \
	static \
	KERNEL_INCLUDES=$(KERNEL_HEADERS_PATH) \
	CFLAGS="$(TARGET_CFLAGS)"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/static $(ROMFSDIR)/bin/ebtables
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ethertypes $(ROMFSDIR)/etc_ro/ethertypes
