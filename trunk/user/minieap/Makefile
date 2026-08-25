include $(ROOTDIR)/rules.mk

PKG_NAME:=minieap
PKG_VERSION:=0.92.1-pdv
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) \
		LIBICONV_STANDALONE=true \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,--defsym=__IF_IMPL_LIST_START__=0 -Wl,--defsym=__IF_IMPL_LIST_END__=0 -Wl,--defsym=__PACKET_PLUGIN_LIST_START__=0 -Wl,--defsym=__PACKET_PLUGIN_LIST_END__=0"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minieap $(ROMFSDIR)/usr/bin/minieap
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/minieap.conf $(ROMFSDIR)/etc_ro/minieap.conf
