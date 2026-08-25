include $(ROOTDIR)/rules.mk

PKG_NAME:=xupnpd
PKG_VERSION:=1.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	# Build lua inside the build directory so the shared source tree is
	# never polluted with .o/liblua.a. Stale objects from a previous libc
	# (uClibc) reference __ctype_b and break musl builds.
	rm -rf $(PKG_BUILD_DIR)/lua-5.1.5
	$(CP) $(ROOTDIR)/user/lua51/lua-5.1.5 $(PKG_BUILD_DIR)/lua-5.1.5
	$(MAKE) -C $(PKG_BUILD_DIR) embedded LUA=$(PKG_BUILD_DIR)/lua-5.1.5/src
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xupnpd $(ROMFSDIR)/usr/bin/xupnpd
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/xupnpd
	$(INSTALL_DIR) $(ROMFSDIR)/usr/share/xupnpd
	$(CP) $(PKG_BUILD_DIR)/*.lua $(ROMFSDIR)/etc_ro/xupnpd/
	$(CP) $(PKG_BUILD_DIR)/ui $(ROMFSDIR)/usr/share/xupnpd/
	$(CP) $(PKG_BUILD_DIR)/www $(ROMFSDIR)/usr/share/xupnpd/
	$(CP) $(PKG_BUILD_DIR)/profiles $(ROMFSDIR)/etc_ro/xupnpd/
	$(CP) $(PKG_BUILD_DIR)/plugins $(ROMFSDIR)/etc_ro/xupnpd/
