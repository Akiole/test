# Lua 5.1.5 with cjson and nixio modules - bundled source

include $(ROOTDIR)/rules.mk

PKG_NAME:=lua51
PKG_VERSION:=5.1.5
SRC_DIR:=.

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -DLUA_USE_LINUX -fPIC -std=gnu99
LUA_DIR:=lua-5.1.5
CJSON_DIR:=lua-cjson-2.1.0
NIXIO_DIR:=lua-nixio-0.3

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR)/$(LUA_DIR) \
		CC="$(CC)" \
		AR="$(AR) rcu" \
		RANLIB="$(RANLIB)" \
		INSTALL_ROOT=/usr \
		CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
		PKG_VERSION="5.1.5" \
		MYLDFLAGS="$(TARGET_LDFLAGS)" \
		linux
	$(MAKE) -C $(PKG_BUILD_DIR)/$(LUA_DIR) INSTALL_TOP=$(STAGING_DIR) install
	rm -f $(STAGING_DIR)/lib/liblua.a
	$(MAKE) -C $(PKG_BUILD_DIR)/$(CJSON_DIR) PREFIX=$(STAGING_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)/$(NIXIO_DIR)/src
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_BUILD_DIR)/$(LUA_DIR)/src/liblua.so.5.1.5 $(ROMFSDIR)/lib/
	$(CP) $(PKG_BUILD_DIR)/$(LUA_DIR)/src/liblua.so $(ROMFSDIR)/lib/
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(LUA_DIR)/src/lua $(ROMFSDIR)/usr/bin/lua
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/lua/5.1/lib
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/lua/5.1/share
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(CJSON_DIR)/cjson.so $(ROMFSDIR)/etc_ro/lua/5.1/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(NIXIO_DIR)/src/nixio.so $(ROMFSDIR)/etc_ro/lua/5.1/lib/
	$(CP) $(PKG_BUILD_DIR)/$(CJSON_DIR)/lua/ $(ROMFSDIR)/etc_ro/lua/5.1/share/
	$(CP) $(PKG_BUILD_DIR)/$(NIXIO_DIR)/root/usr/lib/lua/ $(ROMFSDIR)/etc_ro/lua/5.1/share/
