include $(ROOTDIR)/rules.mk

PKG_NAME:=webdav
PKG_VERSION:=5.17.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/hacdias/webdav/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2ef3605a0d52ffb190ed854630a0e2c8772cca8788375558b7f25153c981b622

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -trimpath \
		-ldflags "-s -w -buildid=" \
		-o webdav .; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/webdav $(ROMFSDIR)/usr/bin/webdav
