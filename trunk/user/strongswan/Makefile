include $(ROOTDIR)/rules.mk

PKG_NAME:=strongswan
PKG_VERSION:=6.1.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://download.strongswan.org/
PKG_HASH:=fe6c97481298767213cfc2e9a1da29fdd8018d481ff4cb9cf0283099654f20d4
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

ifneq ($(IS_DARWIN),)
CONFIGURE_VARS += \
	YACC="/opt/homebrew/opt/bison/bin/bison -y" \
	BISON="/opt/homebrew/opt/bison/bin/bison" \
	PYTHON="/usr/bin/python3"
endif

# strongswan 6.x refactored crypto plugins: aes, des, md5, sha1, sha2,
# hmac, rc2, gmp, fips-prf, pkcs12, eap-tls, eap-mschapv2 are now
# opt-in (--enable-*) and default off.  We simply omit them.
# The old --disable-* flags for these no longer exist.

CONFIGURE_ARGS += \
	--prefix=/usr \
	--sysconfdir=/etc/storage/strongswan \
	--with-sysroot=$(STAGING_DIR) \
	--disable-pki \
	--disable-cmac \
	--disable-xcbc \
	--disable-vici \
	--disable-swanctl \
	--disable-dnskey \
	--disable-pgp \
	--disable-sshkey \
	--disable-constraints \
	--disable-revocation \
	--disable-random \
	--disable-pkcs7 \
	--disable-openssl \
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
	$(CP) $(STAGING_DIR)/lib/ipsec/*.so* $(ROMFSDIR)/usr/lib/ipsec/
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/charon $(ROMFSDIR)/usr/libexec/ipsec/charon
	$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/_updown $(ROMFSDIR)/usr/libexec/ipsec/_updown
	-$(INSTALL_BIN) $(STAGING_DIR)/lib/ipsec/xfrmi $(ROMFSDIR)/usr/libexec/ipsec/xfrmi
