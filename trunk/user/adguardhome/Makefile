include $(ROOTDIR)/rules.mk

PKG_NAME:=AdGuardHome
PKG_VERSION:=0.107.79

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/AdGuardHome/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5f4fa119f24ea741bb8cecfa74203165fe6b86b904cef05ff429fb227b07d425

include $(INCLUDE_DIR)/package.mk

LD_FLAGS:= \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.channel=release \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.version=$(PKG_VERSION)

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		NODE_OPTIONS=--openssl-legacy-provider make js-deps js-build; \
		zip -r embed.zip build; \
	)
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -o AdGuardHome \
		-trimpath -ldflags "$(LD_FLAGS) -s -w -buildid=" \
		.; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./adguardhome.sh $(ROMFSDIR)/usr/bin/adguardhome.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AdGuardHome $(ROMFSDIR)/usr/bin/AdGuardHome
