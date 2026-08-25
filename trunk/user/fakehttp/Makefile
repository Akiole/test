include $(ROOTDIR)/rules.mk

PKG_NAME:=fakehttp
PKG_VERSION:=0.9.18
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CROSS_PREFIX=$(TARGET_CROSS) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_CROSS)strip" \
		VERSION=$(PKG_VERSION) \
		CFLAGS="$(TARGET_CFLAGS) -std=c99 -Iinclude -O3" \
		LDFLAGS="$(TARGET_LDFLAGS) -lnetfilter_queue -lnfnetlink -lmnl" \
		all
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/fakehttp $(ROMFSDIR)/usr/bin/fakehttp
