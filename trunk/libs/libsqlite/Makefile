include $(ROOTDIR)/rules.mk

PKG_NAME:=sqlite
PKG_VERSION:=3540000
PKG_SOURCE:=sqlite-autoconf-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.sqlite.org/2026/
PKG_HASH:=134ec0802dda5795816e25d25872d20b312cb3973438c49b30bc40b7705ea9ed
PKG_BUILD_DIR:=$(BUILD_DIR)/sqlite-autoconf-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# SQLite configure does not support --target
CONFIGURE_ARGS := $(filter-out --target=%,$(CONFIGURE_ARGS))

CONFIGURE_ARGS += \
	--disable-readline \
	--disable-load-extension \
	--disable-debug \
	--disable-static \
	--enable-shared

TARGET_CFLAGS += \
	-DSQLITE_ENABLE_COLUMN_METADATA \
	-DSQLITE_ENABLE_API_ARMOR

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libsqlite3.so* $(ROMFSDIR)/lib/