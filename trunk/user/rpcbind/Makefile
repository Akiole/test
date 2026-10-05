include $(ROOTDIR)/rules.mk

PKG_NAME:=rpcbind
PKG_VERSION:=1.3.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/linux-nfs/rpcbind/tar.gz/rpcbind-1_3_1?
PKG_HASH:=8c04bbe12f71c31d77a837e02194757489304020de38007ceac02d0bbe6b7457
PKG_BUILD_DIR:=$(BUILD_DIR)/rpcbind-rpcbind-1_3_1
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
