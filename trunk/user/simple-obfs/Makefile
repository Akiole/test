include $(ROOTDIR)/rules.mk

PKG_NAME:=simple-obfs
PKG_VERSION:=0.0.5
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--prefix=/usr \
	--disable-ssp \
	--disable-assert \
	--disable-documentation

TARGET_CFLAGS += -I$(STAGING_DIR)/include -Wno-error=stringop-overread

CONFIGURE_VARS += \
	LIBS="-lpthread -lm"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/obfs-local $(ROMFSDIR)/usr/bin/obfs-local
