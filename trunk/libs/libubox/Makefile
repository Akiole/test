include $(ROOTDIR)/rules.mk

PKG_NAME:=libubox
PKG_VERSION:=20261011
PKG_SOURCE:=$(PKG_NAME)-master.tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openwrt/libubox/tar.gz/refs/heads/master?
PKG_HASH:=28f1baf39896ed391bd89c61bf85486edc53434b3624e7a85e14cdb2b67c7452
PKG_BUILD_DIR:=$(BUILD_DIR)/libubox-master

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_LUA=OFF \
	-DBUILD_EXAMPLES=OFF

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR=$(PKG_INSTALL_DIR) install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/include/libubox
	$(CP) $(PKG_INSTALL_DIR)/include/libubox/*.h $(1)/include/libubox/
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libubox.so $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libubox.a $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libblobmsg_json.so $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libblobmsg_json.a $(1)/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libubox.so $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libblobmsg_json.so $(ROMFSDIR)/lib/
