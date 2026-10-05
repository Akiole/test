include $(ROOTDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.14.3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SagerNet/sing-box/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9a8e3712a5f611ad95f1d16874bbdcdffbd3b8eed16dae2d71ce7042a33c3386

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle GOMIPS=softfloat CGO_ENABLED=0 \
		go build -v -trimpath -tags "with_gvisor,with_quic,with_utls,with_wireguard,with_clash_api" \
		-ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$(PKG_VERSION)' -s -w -buildid=" \
		./cmd/sing-box; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(ROMFSDIR)/usr/bin/sing-box
