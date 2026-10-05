include $(ROOTDIR)/rules.mk

PKG_NAME:=naiveproxy
PKG_VERSION:=150.0.7871.63-1

include $(INCLUDE_DIR)/package.mk

STATIC_FILE:=$(PKG_NAME)-v$(PKG_VERSION)-openwrt-mipsel_24kc-static.tar.xz
STATIC_SUBDIR:=$(PKG_NAME)-v$(PKG_VERSION)-openwrt-mipsel_24kc-static
define Download/$(PKG_NAME)-static
	URL:=https://github.com/klzgrad/naiveproxy/releases/download/v$(PKG_VERSION)
	URL_FILE:=$(STATIC_FILE)
	FILE:=$(STATIC_FILE)
	HASH:=741b26a2425244f66adf99d93ed3cd41697aa6ba81660157b1f8f7c8dbf8374f
endef

define Build/Prepare
	tar xf $(DL_DIR)/$(STATIC_FILE) -C $(PKG_BUILD_DIR)
endef


define Build/Compile
	$(TARGET_CROSS)strip $(PKG_BUILD_DIR)/$(STATIC_SUBDIR)/naive
endef

$(eval $(call Download,$(PKG_NAME)-static))
$(eval $(call BuildPackage,naiveproxy))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(STATIC_SUBDIR)/naive $(ROMFSDIR)/usr/bin/naive
