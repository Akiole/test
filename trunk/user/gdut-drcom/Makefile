include $(ROOTDIR)/rules.mk

PKG_NAME:=gdut-drcom
PKG_VERSION:=1.6.8
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# plain hand-written Makefile in src/, no configure step

MAKE_PATH := src

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin $(ROMFSDIR)/etc_ro/gdut-drcom
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/gdut-drcom $(ROMFSDIR)/usr/bin/gdut-drcom
	$(CP) $(PKG_BUILD_DIR)/src/gdut-drcom.conf $(ROMFSDIR)/etc_ro/gdut-drcom/gdut-drcom.conf
