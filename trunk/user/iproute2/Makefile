include $(ROOTDIR)/rules.mk

PKG_NAME:=iproute2
PKG_VERSION:=7.2.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.kernel.org/pub/linux/utils/net/iproute2
PKG_HASH:=4c2fa124c2cf0afd7ca34d1eeacba6ba048a56f6374e2aab93dafbdbd4eea9c0

include $(INCLUDE_DIR)/package.mk

# iproute2 7.x ships a custom (non-autotools) configure script that only
# generates config.mk.  The build system passes autotools-style --host/--build
# flags which the script rejects.  Skip autotools configure entirely; the
# Makefile uses "-include config.mk" (optional) and our patches already set
# CC and SUBDIRS directly.  Provide LIBDIR via make flags.

# musl already provides name_to_handle_at/open_by_handle_at in fcntl.h.
# Tell iproute2 not to provide its own fallback definitions.
TARGET_CFLAGS += -DHAVE_HANDLE_AT

MAKE_FLAGS += LIBDIR=/lib CONF_COLOR=COLOR_OPT_NEVER

# On macOS hosts, system bison is a stub that requires full Xcode.
# Use homebrew bison for yacc/lex code generation.
ifneq ($(IS_DARWIN),)
MAKE_FLAGS += YACC="/opt/homebrew/opt/bison/bin/bison -y"
endif

define Build/Configure
	# iproute2 uses a simple custom configure, not autotools.
	# Skip it - our Makefile patch handles CC and SUBDIRS.
	# Create empty config.mk so -include config.mk succeeds.
	touch $(PKG_BUILD_DIR)/config.mk
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip/ip $(ROMFSDIR)/bin/ip
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SQM),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tc/tc $(ROMFSDIR)/bin/tc
endif
