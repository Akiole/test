include $(ROOTDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=3.3.5
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

SSR_PKG_NAME:=shadowsocksr-libev
SSR_PKG_VERSION:=master-e2373d7
SSR_SRC_DIR:=./$(SSR_PKG_NAME)-$(SSR_PKG_VERSION)
SSR_BUILD_DIR:=$(BUILD_DIR)/$(SSR_PKG_NAME)-$(SSR_PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	$(call Build/Prepare/Default)
	@if [ "$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)" = "y" ] && [ ! -d $(SSR_BUILD_DIR) ]; then \
		echo "Copying shadowsocksr-libev source..."; \
		mkdir -p $(SSR_BUILD_DIR); \
		cp -fpR $(CURDIR)/$(SSR_SRC_DIR)/. $(SSR_BUILD_DIR)/; \
	fi
endef

define Build/Configure
	@echo "Configuring shadowsocks-libev..."
	(cd $(PKG_BUILD_DIR); \
		$(CONFIGURE_VARS) \
		ac_cv_prog_PCRE_CONFIG="$(STAGING_DIR)/bin/pcre-config" \
		./configure \
			--prefix=/usr \
			--with-pcre=$(STAGING_DIR) \
			--disable-documentation \
			--disable-ssp \
			--disable-assert \
			--host=$(HOST_TARGET) \
			--build=$(HOST_BUILD) \
	)
	@if [ "$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)" = "y" ]; then \
		echo "Configuring shadowsocksr-libev..."; \
		(cd $(SSR_BUILD_DIR); \
			aclocal -I m4; autoreconf -fi; automake -a --copy; \
			$(CONFIGURE_VARS) \
			ac_cv_prog_PCRE_CONFIG="$(STAGING_DIR)/bin/pcre-config" \
			./configure \
				--prefix=/usr \
				--with-pcre=$(STAGING_DIR) \
				--disable-documentation \
				--disable-ssp \
				--disable-assert \
				--enable-system-shared-lib \
				--with-crypto-library=mbedtls \
				--with-zlib=$(STAGING_DIR) \
				--host=$(HOST_TARGET) \
				--build=$(HOST_BUILD) \
		); \
	fi
endef

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) CFLAGS="$(TARGET_CFLAGS) -Wno-error=sizeof-pointer-memaccess"
	@if [ "$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)" = "y" ]; then \
		$(MAKE) -j$(HOST_NCPU) -C $(SSR_BUILD_DIR) CFLAGS="$(TARGET_CFLAGS) -Wno-error=sizeof-pointer-memaccess"; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./scripts/shadowsocks.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/ss-monitor $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/ss-rules $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/update_dlink.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_BIN) ./scripts/update_gfwlist.sh $(ROMFSDIR)/usr/bin/
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./oversea/oversea_list.conf $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./gfwlist/gfwlist_list.conf $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_dom.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./uss_dom.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_ip.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_lan_bip.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_lan_gmip.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_lan_ip.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_wan_ip.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DATA) ./ss_dlink.sh $(ROMFSDIR)/etc_ro/
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/ss
	$(INSTALL_DATA) ./ss/* $(ROMFSDIR)/etc_ro/ss/
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(SSR_BUILD_DIR)/src/ss-redir $(ROMFSDIR)/usr/bin/ssr-redir
	$(INSTALL_BIN) $(SSR_BUILD_DIR)/src/ss-local $(ROMFSDIR)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(ROMFSDIR)/usr/bin/ss-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(ROMFSDIR)/usr/bin/ss-local
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSSERVER),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-server $(ROMFSDIR)/usr/bin/ss-server
endif
