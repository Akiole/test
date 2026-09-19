include $(ROOTDIR)/rules.mk

PKG_NAME:=ppp
PKG_VERSION:=2.4.7

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

SRC_DIR=./ppp-2.4.7

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(PKG_BUILD_DIR)/linux/Makefile.top $(PKG_BUILD_DIR)/Makefile
endef

define Build/Configure
	# pppd 2.4.7 uses plain Makefile, skip autoconf
endef

MAKE_FLAGS += \
	$(if $(CONFIG_IPV6),HAVE_INET6=y,) \
	COPTS="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)" \
	INSTALL="install"

$(eval $(call BuildPackage,ppp))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pppd/pppd $(ROMFSDIR)/usr/sbin/pppd
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/pppd
	$(CP) $(PKG_BUILD_DIR)/pppd/plugins/rp-pppoe/rp-pppoe.so $(ROMFSDIR)/usr/lib/pppd/
	$(CP) $(PKG_BUILD_DIR)/pppd/plugins/pppol2tp/pppol2tp.so $(ROMFSDIR)/usr/lib/pppd/
	$(CP) $(PKG_BUILD_DIR)/pppd/plugins/pptp/pptp.so $(ROMFSDIR)/usr/lib/pppd/
