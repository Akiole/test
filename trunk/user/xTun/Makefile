include $(ROOTDIR)/rules.mk

PKG_NAME:=xTun
PKG_VERSION:=0.6.5
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lparam/xTun/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=acbe30d3c34cd9c0bd308367d0f2fc24b9584517461245b661b0ef06cd35f5bc

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) HOST=$(HOST_TARGET)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(STRIP) $(PKG_BUILD_DIR)/xTun
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xTun $(ROMFSDIR)/usr/bin/xTun
	$(INSTALL_BIN) ./xTun.sh $(ROMFSDIR)/usr/bin/xTun.sh
