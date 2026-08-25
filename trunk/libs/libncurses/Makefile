include $(ROOTDIR)/rules.mk

PKG_NAME:=ncurses
PKG_VERSION:=6.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# uClibc toolchain now has wchar support enabled (CT_LIBC_UCLIBC_WCHAR=y),
# so --enable-widec builds libncursesw with full UTF-8 / wide-char support.
CONFIGURE_ARGS += \
	--with-terminfo-dirs=/usr/share/terminfo \
	--with-default-terminfo-dir=/usr/share/terminfo \
	--with-pkg-config-libdir=/lib/pkgconfig \
	--without-ada \
	--without-termlib \
	--without-progs \
	--without-tests \
	--without-manpages \
	--enable-widec \
	--with-shared \
	--without-debug \
	--without-profile \
	--enable-overwrite \
	--enable-pc-files

# macOS host: pre-create lib/ dir and ensure shared lib rules exist.
# ncurses 6.6 mk-1st.awk sometimes fails to emit ../lib rules on macOS.
define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/lib
endef

# macOS host tic is too old for ncurses 6.6 terminfo; prefer brew's
define Build/Install
	+$(MAKE_VARS) \
	PATH="$(if $(filter Darwin,$(shell uname)),$(HOMEBREW_PREFIX)/opt/ncurses/bin:$(PATH),$(PATH))" \
	$(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_INSTALL_FLAGS) \
		install
	rm -f $(STAGING_DIR)/lib/libncurses*.a
	# Compatibility symlink: packages that hardcode -lncurses still link
	# against the wide library.
	ln -sf libncursesw.so $(STAGING_DIR)/lib/libncurses.so
	ln -sf libncursesw.so.6 $(STAGING_DIR)/lib/libncurses.so.6
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libncursesw.so* $(ROMFSDIR)/lib/
	ln -sf libncursesw.so $(ROMFSDIR)/lib/libncurses.so
	ln -sf libncursesw.so.6 $(ROMFSDIR)/lib/libncurses.so.6