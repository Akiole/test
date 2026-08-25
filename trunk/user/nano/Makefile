include $(ROOTDIR)/rules.mk

PKG_NAME:=nano
PKG_VERSION:=9.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-tiny \
	--enable-utf8 \
	--disable-nls

# uClibc provides utime(); cross-compile cannot detect it, so force it.
CONFIGURE_VARS += ac_cv_func_utime=yes

# Wide ncurses (libncursesw) now that uClibc has wchar support.
MAKE_FLAGS += LIBS="-lncursesw"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/nano $(ROMFSDIR)/usr/bin/nano
