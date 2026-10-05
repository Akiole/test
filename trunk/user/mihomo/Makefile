include $(ROOTDIR)/rules.mk

PKG_NAME:=mihomo
PKG_VERSION:=1.19.32

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/MetaCubeX/mihomo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ab130b7fab3893d01aa44c0d39be34a26da716c1d36832fbac9fa054a1d862a0

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle GOMIPS=softfloat CGO_ENABLED=0 \
		go build -v -trimpath -tags "with_gvisor,with_low_memory" \
		-ldflags "-X 'github.com/metacubex/mihomo/constant.Version=$(PKG_VERSION)' -s -w -buildid=" \
		.; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mihomo $(ROMFSDIR)/usr/bin/mihomo
	$(INSTALL_BIN) ./scripts/mihomo.sh $(ROMFSDIR)/usr/bin/mihomo.sh
