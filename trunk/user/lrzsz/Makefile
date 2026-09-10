include $(ROOTDIR)/rules.mk

PKG_NAME:=lrzsz
PKG_VERSION:=0.12.20
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# lrzsz 0.12.20 uses K&R old-style function definitions; build with
# gnu89 so its configure test program `main(){return(0);}` compiles.
TARGET_CFLAGS += -std=gnu89

CONFIGURE_ARGS += \
	--disable-nls

MAKE_FLAGS += \
	AR=$(TARGET_CROSS)ar \
	RANLIB=$(TARGET_CROSS)ranlib

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lrz $(ROMFSDIR)/usr/bin/lrz
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lsz $(ROMFSDIR)/usr/bin/lsz
