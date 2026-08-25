include $(ROOTDIR)/rules.mk

PKG_NAME:=mtr
PKG_VERSION:=0.95
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --without-gtk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mtr $(ROMFSDIR)/usr/bin/mtr
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mtr-packet $(ROMFSDIR)/usr/bin/mtr-packet
