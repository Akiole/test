include $(ROOTDIR)/rules.mk

PKG_NAME:=gdut-drcom
PKG_VERSION:=1.6.8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/chenhaowen01/gdut-drcom/tar.gz/$(PKG_VERSION)?
PKG_HASH:=eafd0e6b82062aca923ad9d8dd064a47b9c1a31f7eb73441aeb1c186c10d066a

include $(INCLUDE_DIR)/package.mk

# plain hand-written Makefile in src/, no configure step

MAKE_PATH := src

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin $(ROMFSDIR)/etc_ro/gdut-drcom
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/gdut-drcom $(ROMFSDIR)/usr/bin/gdut-drcom
	$(CP) $(PKG_BUILD_DIR)/src/gdut-drcom.conf $(ROMFSDIR)/etc_ro/gdut-drcom/gdut-drcom.conf
