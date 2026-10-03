include $(ROOTDIR)/rules.mk

PKG_NAME:=openvpn
PKG_VERSION:=2.7.7
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
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
