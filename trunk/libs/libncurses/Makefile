include $(ROOTDIR)/rules.mk

PKG_NAME:=ncurses
PKG_VERSION:=6.6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.gnu.org/gnu/ncurses/
PKG_HASH:=355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk

# ncurses 6.6 top-level Makefile fans out to include/ncurses/panel/menu/form
# subdirs in parallel, but ncurses/Makefile's 'all' target depends on
# ../lib/libncursesw.so.6.6 which is produced by the lib/ subdir.  Under
# -jN this races and fails with "No rule to make target
# '../lib/libncursesw.so.6.6', needed by 'all'".  Force serial build.
# Also override Build/Compile to pre-create output dirs and strip any
# inherited MAKEFLAGS=-jN from the parent environment, which would
# otherwise re-enable parallelism inside ncurses.
define Build/Compile
	mkdir -p $(PKG_BUILD_DIR)/lib $(PKG_BUILD_DIR)/obj_s
	+$(MAKE_VARS) \
	$(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_FLAGS) \
		MAKEFLAGS= \
		libs
endef

CONFIGURE_ARGS += \
	--with-terminfo-dirs=/usr/share/terminfo \
	--with-default-terminfo-dir=/usr/share/terminfo \
	--with-pkg-config-libdir=/lib/pkgconfig \
	--without-ada \
	--without-cxx-binding \
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

define Build/Install
	# Install only libs + headers.  Skip install.data (terminfo database):
	# the host tic on macOS is ncurses 6.0 and cannot write ncurses 6.6
	# entries, failing with "error writing .../terminfo/...".  Firmware
	# does not ship terminfo data anyway.
	$(call Build/Install/Default, install.libs install.includes)
	rm -f $(STAGING_DIR)/lib/libncurses*.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libncursesw.so* $(ROMFSDIR)/lib/