include $(ROOTDIR)/rules.mk

PKG_NAME:=skipdbv2
PKG_VERSION:=1.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sniperpr/skipdbv2/tar.gz/refs/heads/master?
PKG_HASH:=d4ac6bf574f0627a817eb2c6ad57e41016109f646ebfbf26c09f0a5dbb6af065
PKG_BUILD_DIR:=$(BUILD_DIR)/skipdbv2-master

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
# UArray.h uses type-dispatched switch statements that intentionally cover
# only the types valid for each operation; -Wswitch fires on every template
# instantiation.  UArray_utf.c has a %f vs int format mismatch in debug code.
# ev.h (libev) uses type-punning in its watcher init macros, which fires
# -Wstrict-aliasing in every file that calls ev_io_init / ev_timer_init.
EXTRA_CFLAGS := -Wno-switch -Wno-format -Wno-strict-aliasing
CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr

TARGET_LDFLAGS += -lev

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/skipd $(ROMFSDIR)/usr/sbin/skipd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/dbus $(ROMFSDIR)/usr/sbin/dbus
