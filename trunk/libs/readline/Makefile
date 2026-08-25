include $(ROOTDIR)/rules.mk

PKG_NAME:=readline
PKG_VERSION:=8.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-install-examples \
	--disable-multibyte

TARGET_CFLAGS += \
	-I$(STAGING_DIR)/include

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libreadline.so* $(ROMFSDIR)/lib/