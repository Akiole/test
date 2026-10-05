include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.11
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/miniupnp/miniupnp/tar.gz/miniupnpd_2_3_11?
PKG_HASH:=25521370ec33b8c075ca7b073cda2a98a2d449e6c09b10acbe5a9d038bca1017

include $(INCLUDE_DIR)/package.mk

# miniupnpd 2.3.x uses its own configure script (not standard autoconf)
# The GitHub tarball contains the whole miniupnp repo; extract only miniupnpd/
define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(BUILD_DIR)
	mv $(BUILD_DIR)/miniupnp-miniupnpd_2_3_11/miniupnpd/* $(PKG_BUILD_DIR)/
	rm -rf $(BUILD_DIR)/miniupnp-miniupnpd_2_3_11
endef

# Override Build/Configure to avoid standard autoconf options (--target/--host/--build)
# Padavan fixes: enable IPTABLES_143, disable LIB_UUID/BSD_UUID (musl has no uuid)
# Features: IGDv2 + HTTPS + LEASEFILE + PCP_PEER + PORTINUSE

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		chmod +x configure; \
		$(CONFIGURE_VARS) sh ./configure \
			--host-os=Linux \
			--host-os-version=4.4 \
			--host-machine=mips \
			--firewall=iptables \
			--disable-pppconn \
			--igd2 \
			--https \
			--https-cert=/tmp/miniupnpd-cert.pem \
			--https-key=/tmp/miniupnpd-key.pem \
			--leasefile \
			--pcp-peer \
			--portinuse \
			--vendorcfg; \
	)
	$(SED) 's/^#undef IPTABLES_143/#define IPTABLES_143 1/' $(PKG_BUILD_DIR)/config.h
	$(SED) 's/^#define LIB_UUID/\/\/ #define LIB_UUID/' $(PKG_BUILD_DIR)/config.h
	$(SED) 's/^#define BSD_UUID/\/\/ #define BSD_UUID/' $(PKG_BUILD_DIR)/config.h
endef

MAKE_FLAGS += \
	-f Makefile.linux \
	CFLAGS="$(TARGET_CFLAGS) -Os -fno-strict-aliasing -fno-common -Wall" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDLIBS="-lssl -lcrypto -lip4tc -lxtables -lcap-ng"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(ROMFSDIR)/usr/bin/miniupnpd
