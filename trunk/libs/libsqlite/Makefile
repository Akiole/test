include $(ROOTDIR)/rules.mk

PKG_NAME:=sqlite
PKG_VERSION:=3530300
SRC_DIR:=./$(PKG_NAME)-autoconf-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# SQLite configure does not support --target
CONFIGURE_ARGS := $(filter-out --target=%,$(CONFIGURE_ARGS))

# sqlite >= 3.5x autoconf: fts3/4/5, rtree, session are opt-in (off by
# default), JSON and threadsafe are on by default; only disable what we
# explicitly do not want.
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