include $(ROOTDIR)/rules.mk

PKG_NAME:=neofetch
PKG_VERSION:=7.1.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dylanaraps/neofetch/tar.gz/$(PKG_VERSION)?
PKG_HASH:=58a95e6b714e41efc804eca389a223309169b2def35e57fa934482a6b47c27e7

include $(INCLUDE_DIR)/package.mk


define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/neofetch $(ROMFSDIR)/usr/bin/neofetch
