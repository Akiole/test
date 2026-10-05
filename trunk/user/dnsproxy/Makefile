include $(ROOTDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=1.1.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/vietor/dnsproxy/tar.gz/$(PKG_VERSION)?
PKG_HASH:=68f5b13ad984a29d5a31cc5a6260151107fbfbef4b49576b54a9f2ce07378985

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dnsproxy $(ROMFSDIR)/usr/bin/dnsproxy
