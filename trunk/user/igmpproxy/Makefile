include $(ROOTDIR)/rules.mk

PKG_NAME:=igmpproxy
PKG_VERSION:=0.4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pali/igmpproxy/tar.gz/$(PKG_VERSION)?
PKG_HASH:=b905c492aa54212d022220631ab3176f2f5052c4f9a31e369e4d948210f24277
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/igmpproxy $(ROMFSDIR)/bin/igmpproxy
	$(INSTALL_DIR) $(ROMFSDIR)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/igmpproxy.conf $(ROMFSDIR)/etc/igmpproxy.conf
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./igmpproxy.sh $(ROMFSDIR)/usr/bin/igmpproxy.sh
