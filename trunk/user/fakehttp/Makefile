include $(ROOTDIR)/rules.mk

PKG_NAME:=fakehttp
PKG_VERSION:=0.9.18
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/MikeWang000000/FakeHTTP/tar.gz/$(PKG_VERSION)?
PKG_HASH:=c95c4d46e122390b0dcfd8509c708a6fc6817fb3e325cb966bf81a62bae973be
PKG_BUILD_DIR:=$(BUILD_DIR)/FakeHTTP-$(PKG_VERSION)

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
