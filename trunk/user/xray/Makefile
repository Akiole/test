include $(ROOTDIR)/rules.mk

PKG_NAME:=xray
PKG_VERSION:=26.10.10

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/XTLS/Xray-core/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=bc4b3fbe9f2612a7e8b7fffd4b7195f00ad4aa28478f3621fce925cb6190c036
PKG_BUILD_DIR:=$(BUILD_DIR)/Xray-core-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux GOARCH=mipsle CGO_ENABLED=0 \
		go build -v -o xray \
		-trimpath -ldflags "-s -w -buildid=" \
		./main; \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(ROMFSDIR)/usr/bin/$(PKG_NAME)
