# Lua 5.1.5 with cjson and nixio modules - download build mode

include $(ROOTDIR)/rules.mk

PKG_NAME:=lua51
PKG_VERSION:=5.1.5
PKG_SOURCE:=lua-5.1.5.tar.gz
PKG_SOURCE_URL:=https://www.lua.org/ftp/
PKG_HASH:=2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -DLUA_USE_LINUX -fPIC -std=gnu99
LUA_DIR:=lua-5.1.5
CJSON_DIR:=lua-cjson-2.1.0
NIXIO_DIR:=lua-nixio-0.3

# Additional source tarballs bundled alongside the main Lua distribution.
# nixio upstream URL is no longer available; vendored tarball kept in package dir.
define Download/cjson
  URL:=https://www.kyne.au/~mark/software/download/
  FILE:=lua-cjson-2.1.0.tar.gz
  HASH:=51bc69cd55931e0cba2ceae39e9efa2483f4292da3a88a1ed470eda829f6c778
endef
$(eval $(call Download,cjson))

define Download/nixio
  URL:=file://$(CURDIR)
  FILE:=lua-nixio-0.3.tar.gz
  HASH:=4fe49c9a56064c037a5c82ed7e7dd5f02923944f4fc5b43b32677e765fd73ab9
endef
$(eval $(call Download,nixio))

# Unpack all three tarballs into PKG_BUILD_DIR so that the main Makefile
# references $(PKG_BUILD_DIR)/lua-5.1.5, .../lua-cjson-2.1.0 and
# .../lua-nixio-0.3 exactly as in the previous bundled-source layout.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(TAR) -C $(PKG_BUILD_DIR) -xf $(DL_DIR)/$(PKG_SOURCE)
	$(TAR) -C $(PKG_BUILD_DIR) -xf $(DL_DIR)/lua-cjson-2.1.0.tar.gz
	$(TAR) -C $(PKG_BUILD_DIR) -xf $(DL_DIR)/lua-nixio-0.3.tar.gz
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR))
endef

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR)/$(LUA_DIR)/src \
		CC="$(CC)" \
		AR="$(AR) rcu" \
		RANLIB="$(RANLIB)" \
		INSTALL_ROOT=/usr \
		CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
		PKG_VERSION="5.1.5" \
		MYLDFLAGS="$(TARGET_LDFLAGS)" \
		MYCFLAGS=-DLUA_USE_LINUX \
		MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncursesw" \
		all
	# Build shared library from static archive
	cd $(PKG_BUILD_DIR)/$(LUA_DIR)/src && $(CC) -shared -o liblua.so.5.1.5 $(TARGET_LDFLAGS) -Wl,--whole-archive liblua.a -Wl,--no-whole-archive -lm
	ln -sf liblua.so.5.1.5 $(PKG_BUILD_DIR)/$(LUA_DIR)/src/liblua.so
	$(MAKE) -C $(PKG_BUILD_DIR)/$(LUA_DIR) INSTALL_TOP=$(STAGING_DIR) install
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
