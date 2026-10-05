include $(ROOTDIR)/rules.mk

PKG_NAME:=minieap
PKG_VERSION:=0.93
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/updateing/minieap/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=752cec83f453ab2b44503156e0a84a82c475b9a231f45d407b6b7eb75de60f68

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
