include $(ROOTDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=3.3.6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$(PKG_VERSION)
PKG_HASH:=ee83b43b36d6a51cfbee72254b6088d4b625feadf06cc2f0bcb810c8236438a5


SSR_PKG_NAME:=shadowsocksr-libev
SSR_PKG_VERSION:=e2373d7
SSR_FILE:=$(SSR_PKG_NAME)-e2373d7199102f383b741da148b989c7c1e8832e.tar.gz
SSR_SUBDIR:=$(SSR_PKG_NAME)-e2373d7199102f383b741da148b989c7c1e8832e
SSR_BUILD_DIR:=$(BUILD_DIR)/$(SSR_SUBDIR)
define Download/ssr
	URL:=https://codeload.github.com/shadowsocksr-backup/shadowsocksr-libev/tar.gz
	URL_FILE:=e2373d7199102f383b741da148b989c7c1e8832e
	FILE:=$(SSR_FILE)
	HASH:=53713acd2931c16f8998bc4b9e7ed6e738d7cea7bd71848b8e76d995bd984028
endef

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

$(eval $(call Download,ssr))

CMAKE_OPTIONS += \
	-DWITH_STATIC=ON \
	-DWITH_EMBEDDED_SRC=ON \
	-DENABLE_CONNMARKTOS=OFF \
	-DENABLE_NFTABLES=OFF \
	-DMBEDTLS_INCLUDE_DIR=$(STAGING_DIR)/include \
	-DMBEDTLS_CRYPTO_LIBRARY=$(STAGING_DIR)/lib/libmbedcrypto.so \
	-DMBEDTLS_TLS_LIBRARY=$(STAGING_DIR)/lib/libmbedtls.so \
	-DLIBSODIUM=$(STAGING_DIR)/lib/libsodium.so \
	-DLIBSODIUM_SHARED=$(STAGING_DIR)/lib/libsodium.so \
	-DLIBMBEDTLS=$(STAGING_DIR)/lib/libmbedtls.so \
	-DLIBMBEDCRYPTO=$(STAGING_DIR)/lib/libmbedcrypto.so \
	-DLIBMBEDTLS_SHARED=$(STAGING_DIR)/lib/libmbedtls.so \
	-DLIBMBEDCRYPTO_SHARED=$(STAGING_DIR)/lib/libmbedcrypto.so \
	-DLIBEV=$(STAGING_DIR)/lib/libev.so \
	-DLIBEV_SHARED=$(STAGING_DIR)/lib/libev.so \
	-DLIBUDNS=$(STAGING_DIR)/lib/libcares.so \
	-DLIBUDNS_SHARED=$(STAGING_DIR)/lib/libcares.so \
	-DLIBPCRE2=$(STAGING_DIR)/lib/libpcre2-8.so \
	-DLIBPCRE2_SHARED=$(STAGING_DIR)/lib/libpcre2-8.so

# Git submodules (not included in release tarball)
LIBCORK_VERSION:=074e074b26e9e372e90e6ade215217763c8644aa
LIBCORK_SOURCE:=libcork-$(LIBCORK_VERSION).tar.gz
LIBCORK_SOURCE_URL:=https://codeload.github.com/shadowsocks/libcork/tar.gz/$(LIBCORK_VERSION)?
LIBCORK_HASH:=f8e4b637f35bbe0bc5d893164e439aefa61d2b6fe58b0a79c30e42f5f54f08e0

LIBIPSET_VERSION:=3ea7fe30adf4b39b27d932e5a70a2ddce4adb508
LIBIPSET_SOURCE:=libipset-$(LIBIPSET_VERSION).tar.gz
LIBIPSET_SOURCE_URL:=https://codeload.github.com/shadowsocks/ipset/tar.gz/$(LIBIPSET_VERSION)?
LIBIPSET_HASH:=89be31c635814948c0887f660d2a98f4bc4b1dc6691a57d653c2466a8098f887

LIBBLOOM_VERSION:=437e1add5a2b9a87797d8c648df7cf5f3ee155a8
LIBBLOOM_SOURCE:=libbloom-$(LIBBLOOM_VERSION).tar.gz
LIBBLOOM_SOURCE_URL:=https://codeload.github.com/shadowsocks/libbloom/tar.gz/$(LIBBLOOM_VERSION)?
LIBBLOOM_HASH:=6e0131faa238c5dd15da4b43931d2f628590ba07e1177a47ead8e4dd18752459

define Download/libcork
  URL:=https://codeload.github.com/shadowsocks/libcork/tar.gz/$(LIBCORK_VERSION)?
  FILE:=$(LIBCORK_SOURCE)
  HASH:=$(LIBCORK_HASH)
endef

define Download/libipset
  URL:=https://codeload.github.com/shadowsocks/ipset/tar.gz/$(LIBIPSET_VERSION)?
  FILE:=$(LIBIPSET_SOURCE)
  HASH:=$(LIBIPSET_HASH)
endef

define Download/libbloom
  URL:=https://codeload.github.com/shadowsocks/libbloom/tar.gz/$(LIBBLOOM_VERSION)?
  FILE:=$(LIBBLOOM_SOURCE)
  HASH:=$(LIBBLOOM_HASH)
endef

$(eval $(call Download,libcork))
$(eval $(call Download,libipset))
$(eval $(call Download,libbloom))

define Build/Prepare
	$(call Build/Prepare/Default)
	# Remove empty submodule dirs from release tarball, then extract real submodules
	rm -rf $(PKG_BUILD_DIR)/libcork $(PKG_BUILD_DIR)/libipset $(PKG_BUILD_DIR)/libbloom
	tar xf $(DL_DIR)/$(LIBCORK_SOURCE) -C $(PKG_BUILD_DIR)
	mv $(PKG_BUILD_DIR)/libcork-$(LIBCORK_VERSION) $(PKG_BUILD_DIR)/libcork
	tar xf $(DL_DIR)/$(LIBIPSET_SOURCE) -C $(PKG_BUILD_DIR)
	mv $(PKG_BUILD_DIR)/ipset-$(LIBIPSET_VERSION) $(PKG_BUILD_DIR)/libipset
	tar xf $(DL_DIR)/$(LIBBLOOM_SOURCE) -C $(PKG_BUILD_DIR)
	mv $(PKG_BUILD_DIR)/libbloom-$(LIBBLOOM_VERSION) $(PKG_BUILD_DIR)/libbloom
endef

define Build/Configure
	@if [ "$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)" = "y" ] && [ ! -d "$(SSR_BUILD_DIR)" ]; then \
		echo "Extracting shadowsocksr-libev source..."; \
		tar xf "$(DL_DIR)/$(SSR_FILE)" -C "$(BUILD_DIR)"; \
		(cd "$(SSR_BUILD_DIR)" && patch -p1 < "$(CURDIR)/ssr-patches/100-padavan-fixes.patch"); \
	fi
	@echo "Configuring shadowsocks-libev (CMake)..."
	$(call Build/Configure/Default)
	@if [ "$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)" = "y" ]; then \
		echo "Configuring shadowsocksr-libev..."; \
		(cd $(SSR_BUILD_DIR); \
			aclocal -I m4; autoreconf -fi; automake -a --copy; \
			cp -f $$(automake --print-libdir)/config.sub auto/ 2>/dev/null || true; \
			cp -f $$(automake --print-libdir)/config.guess auto/ 2>/dev/null || true; \
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/ss-redir $(ROMFSDIR)/usr/bin/ss-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/ss-local $(ROMFSDIR)/usr/bin/ss-local
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSSERVER),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/ss-server $(ROMFSDIR)/usr/bin/ss-server
endif
