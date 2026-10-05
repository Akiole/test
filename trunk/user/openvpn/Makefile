include $(ROOTDIR)/rules.mk

PKG_NAME:=openvpn
PKG_VERSION:=2.7.8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/OpenVPN/openvpn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=daf18f81040137fc4d3d843088954ae68f6c86c10d3860114078b9c256a3516f
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_VARS += \
	IFCONFIG=/sbin/ifconfig \
	ROUTE=/sbin/route \
	NETSTAT=/bin/netstat

CONFIGURE_ARGS += \
	--prefix=/usr \
	--disable-debug \
	--disable-plugins \
	--disable-pkcs11 \
	--disable-ofb-cfb \
	--disable-selinux \
	--disable-systemd \
	--disable-iproute2 \
	--disable-unit-tests \
	--disable-management \
	--disable-multihome \
	--disable-pf \
	--disable-fragment \
	--disable-def-auth \
	--disable-lzo \
	--disable-lz4 \
	--disable-comp-stub \
	--disable-dco \
	--with-crypto-library=openssl \
	--with-sysroot=$(STAGING_DIR)

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/src/openvpn/openvpn /usr/sbin/openvpn
	$(ROMFSINST) /usr/bin/openvpn-cert.sh
