include $(ROOTDIR)/rules.mk

PKG_NAME:=strongswan
PKG_VERSION:=5.9.14
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

ifneq ($(IS_DARWIN),)
CONFIGURE_VARS += \
	YACC="/opt/homebrew/opt/bison/bin/bison -y" \
	BISON="/opt/homebrew/opt/bison/bin/bison" \
	PYTHON="/usr/bin/python3"
endif

CONFIGURE_ARGS += \
	--prefix=/usr \
	--sysconfdir=/etc/storage/strongswan \
	--with-sysroot=$(STAGING_DIR) \
	--disable-pki \
	--disable-fips-prf \
	--disable-gmp \
	--disable-rc2 \
	--disable-cmac \
	--disable-xcbc \
	--disable-scepclient \
	--disable-vici \
	--disable-swanctl \
	--disable-dnskey \
	--disable-pgp \
	--disable-sshkey \
	--disable-constraints \
	--disable-revocation \
	--disable-random \
	--disable-des \
	--disable-aes \
	--disable-md5 \
	--disable-sha1 \
	--disable-sha2 \
	--disable-pkcs7 \
	--disable-pkcs12 \
	--disable-hmac \
	--disable-openssl \
	--disable-eap-tls \
	--disable-eap-mschapv2 \
	--enable-dhcp \
	--enable-farp \
	--enable-eap-dynamic \
	--enable-eap-identity \
	--enable-xauth-eap \
	--enable-xauth-noauth \
	--enable-systime-fix \
	--enable-monolithic \
	--with-resolv-conf=/etc/resolv.conf \
	--with-user=admin

define Build/Install
	$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_INSTALL_FLAGS) install-strip
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/ipsec
	$(INSTALL_DIR) $(ROMFSDIR)/usr/libexec/ipsec
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(CP) $(STAGING_DIR)/lib/ipsec/*.so* $(ROMFSDIR)/usr/lib/ipsec/
	$(INSTALL_BIN) $(STAGING_DIR)/sbin/ipsec $(ROMFSDIR)/usr/sbin/ipsec
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/charon $(ROMFSDIR)/usr/libexec/ipsec/charon
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/starter $(ROMFSDIR)/usr/libexec/ipsec/starter
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/stroke $(ROMFSDIR)/usr/libexec/ipsec/stroke
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/_updown $(ROMFSDIR)/usr/libexec/ipsec/_updown
