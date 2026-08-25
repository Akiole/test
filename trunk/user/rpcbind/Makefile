include $(ROOTDIR)/rules.mk

PKG_NAME:=rpcbind
PKG_VERSION:=1.2.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fvisibility=hidden

CONFIGURE_ARGS += \
	$(if $(CONFIG_IPV6),--enable-ipv6,--disable-ipv6) \
	--disable-libwrap \
	--disable-debug \
	--disable-warmstarts \
	--with-rpcuser=nobody \
	--without-nss-modules \
	--without-systemdsystemunitdir

CONFIGURE_VARS += \
	TIRPC_CFLAGS="-I$(STAGING_DIR)/include/tirpc" \
	TIRPC_LIBS="-L$(STAGING_DIR)/lib -ltirpc"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpcbind $(ROMFSDIR)/sbin/rpcbind
