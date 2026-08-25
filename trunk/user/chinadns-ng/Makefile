include $(ROOTDIR)/rules.mk

PKG_NAME:=chinadns-ng
PKG_VERSION:=2023.10.28
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# toolchain built with --disable-lto; drop -flto from upstream Makefile

define strip_flto
	$(SED) 's/ -flto//g' $(PKG_BUILD_DIR)/Makefile
endef

Hooks/Prepare/Post += strip_flto

# toolchain built with --disable-lto; disable package LTO too

MAKE_FLAGS += LTOFLAGS=
TARGET_CFLAGS += -fno-lto
TARGET_LDFLAGS += -fno-lto

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chinadns-ng $(ROMFSDIR)/usr/bin/chinadns-ng
