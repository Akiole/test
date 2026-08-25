include $(ROOTDIR)/rules.mk

PKG_NAME:=dns2tcp
PKG_VERSION:=1.1.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# toolchain built with --disable-lto; drop -flto from upstream Makefile

define strip_flto
	$(SED) 's/ -flto//g' $(PKG_BUILD_DIR)/Makefile
endef

Hooks/Prepare/Post += strip_flto

TARGET_CFLAGS += -fno-lto
TARGET_LDFLAGS += -fno-lto

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dns2tcp $(ROMFSDIR)/usr/bin/dns2tcp
