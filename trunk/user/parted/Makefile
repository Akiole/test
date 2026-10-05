include $(ROOTDIR)/rules.mk

PKG_NAME:=parted
PKG_VERSION:=3.8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://ftp.gnu.org/gnu/parted/
PKG_HASH:=a2b7811f47b0ddb1f7b1d0aa456f7c1270da70708ce231c2fe054c7199eafa63

include $(INCLUDE_DIR)/package.mk

# Package-specific warnings (the generic GCC14/gnulib ones are in rules.mk):
# - dos.c has a genuine maybe-uninitialized path; arch/linux.c discards const
#   and uses !!x == y style.  Upstream code, harmless for our use case.
TARGET_CFLAGS += \
	-Wno-maybe-uninitialized \
	-Wno-discarded-qualifiers

CONFIGURE_VARS += \
	LIBS="-liconv"

CONFIGURE_ARGS += \
	--without-readline \
	--disable-shared \
	--disable-static \
	--disable-device-mapper \
	--disable-nls \
	--disable-debug

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/parted/parted $(ROMFSDIR)/sbin/parted
