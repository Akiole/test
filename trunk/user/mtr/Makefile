include $(ROOTDIR)/rules.mk

PKG_NAME:=mtr
PKG_VERSION:=0.96
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/traviscross/mtr/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=73e6aef3fb6c8b482acb5b5e2b8fa7794045c4f2420276f035ce76c5beae632d
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --without-gtk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mtr $(ROMFSDIR)/usr/bin/mtr
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mtr-packet $(ROMFSDIR)/usr/bin/mtr-packet
