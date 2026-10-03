include $(ROOTDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.3.11
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# miniupnpd 2.3.x uses its own configure script (not standard autoconf)
# Override Build/Configure to avoid standard autoconf options (--target/--host/--build)
# Padavan fixes: enable IPTABLES_143, disable LIB_UUID/BSD_UUID (musl has no uuid)
# Features: IGDv2 + HTTPS + LEASEFILE + PCP_PEER + PORTINUSE

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		$(CONFIGURE_VARS) ./configure \
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
