include $(ROOTDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.71.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1dd367d6d822a7fce1d3012fce0a6e778bc90c454e2c7baa0eb1e6de6054c61b

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle GOMIPS=softfloat CGO_ENABLED=0 \
		go build -trimpath -ldflags "-s -w" -tags "frpc,noweb" -o frpc ./cmd/frpc; \
		go build -trimpath -ldflags "-s -w" -tags "frps,noweb" -o frps ./cmd/frps; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FRPC),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/frpc $(ROMFSDIR)/usr/bin/frpc
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FRPS),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/frps $(ROMFSDIR)/usr/bin/frps
endif
	$(INSTALL_BIN) ./frp.sh $(ROMFSDIR)/usr/bin/frp.sh
	$(ROMFSINST) /etc_ro/frp_script.sh
