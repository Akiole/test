include $(ROOTDIR)/rules.mk

PKG_NAME:=fakesip
PKG_VERSION:=0.9.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/MikeWang000000/FakeSIP/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1216d9649fb69e5a1deaf48c3d48c26f9418bd18ffe15f44b0cf33039dbb3478
PKG_BUILD_DIR:=$(BUILD_DIR)/FakeSIP-$(PKG_VERSION)

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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/fakesip $(ROMFSDIR)/usr/bin/fakesip
