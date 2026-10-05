include $(ROOTDIR)/rules.mk

PKG_NAME:=vlmcsd
PKG_VERSION:=svn1113

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Wind4/vlmcsd/tar.gz/$(PKG_VERSION)?
PKG_HASH:=62f55c48f5de1249c2348ab6b96dabbe7e38899230954b0c8774efb01d9c42cc

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) vlmcsd SAFE_MODE=1 CC=$(TARGET_CC_NOCACHE)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vlmcsd $(ROMFSDIR)/usr/bin/vlmcsd
	$(INSTALL_BIN) ./vlmcsd.sh $(ROMFSDIR)/usr/bin/vlmcsd.sh
