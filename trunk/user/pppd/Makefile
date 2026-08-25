include $(ROOTDIR)/rules.mk

PKG_NAME:=ppp
PKG_VERSION:=2.5.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

PPP_BUILD_PLUGIN_DIR:=$(PKG_BUILD_DIR)/pppd/plugins
PPP_STAGE_PLUGIN_DIR:=$(STAGING_DIR)/lib/pppd/$(PKG_VERSION)
PPP_ROMFS_PLUGIN_DIR:=$(ROMFSDIR)/usr/lib/pppd

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PPP_BUILD_PLUGIN_DIR)/pppoe
	mkdir -p $(PPP_BUILD_PLUGIN_DIR)/pppol2tp
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--enable-pppoe \
		--enable-pppol2tp \
		--enable-plugins \
		--with-pcap=linux \
		$(if $(CONFIG_IPV6),--enable-ipv6,) \
		--prefix=/usr \
		--bindir=/usr/sbin \
		--libdir=/lib \
		--disable-versioned-libs \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) all
	$(MAKE) -C $(PPP_BUILD_PLUGIN_DIR)/pppoe $(MAKE_FLAGS)
	$(MAKE) -C $(PPP_BUILD_PLUGIN_DIR)/pppol2tp $(MAKE_FLAGS)
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) install DESTDIR=$(STAGING_DIR)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(STAGING_DIR)/sbin/pppd $(ROMFSDIR)/usr/sbin/pppd
	$(INSTALL_DIR) $(PPP_ROMFS_PLUGIN_DIR)
	$(CP) $(PPP_STAGE_PLUGIN_DIR)/pppoe.so $(PPP_ROMFS_PLUGIN_DIR)/
	$(CP) $(PPP_STAGE_PLUGIN_DIR)/pppol2tp.so $(PPP_ROMFS_PLUGIN_DIR)/
