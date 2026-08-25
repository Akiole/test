include $(ROOTDIR)/rules.mk

PKG_NAME:=htop
PKG_VERSION:=3.5.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

# uClibc now has wchar support; use wide ncurses with unicode.
CONFIGURE_ARGS += \
	--enable-unicode \
	--with-curses=ncursesw

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/htop $(ROMFSDIR)/usr/bin/htop
