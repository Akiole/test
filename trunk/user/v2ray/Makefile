include $(ROOTDIR)/rules.mk

PKG_NAME:=v2ray
PKG_VERSION:=5.54.2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2fly/v2ray-core/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=fd171b094376701aa07f1bb4ab9bf4dc67bd4df014673ec545ad362360341364
PKG_BUILD_DIR:=$(BUILD_DIR)/v2ray-core-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -o v2ray \
		-trimpath -ldflags "-s -w -buildid=" \
		./main; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(ROMFSDIR)/usr/bin/$(PKG_NAME)
