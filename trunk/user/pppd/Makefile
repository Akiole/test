include $(ROOTDIR)/rules.mk

PKG_NAME:=ppp
PKG_VERSION:=2.5.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-radius \
	--disable-pcap \
	--disable-eap-tls \
	--disable-eap-srp \
	$(if $(CONFIG_IPV6),--enable-ipv6cp,--disable-ipv6cp)

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)/include"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/pppd $(ROMFSDIR)/usr/sbin/pppd
	$(INSTALL_DIR) $(ROMFSDIR)/lib/pppd/$(PKG_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/lib/pppd/$(PKG_VERSION)/pppoe.so $(ROMFSDIR)/lib/pppd/$(PKG_VERSION)/
	$(CP) $(PKG_INSTALL_DIR)/lib/pppd/$(PKG_VERSION)/pppol2tp.so $(ROMFSDIR)/lib/pppd/$(PKG_VERSION)/
