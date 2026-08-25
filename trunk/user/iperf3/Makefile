include $(ROOTDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.21
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -D_GNU_SOURCE

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--without-openssl

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/iperf3 $(ROMFSDIR)/bin/iperf3
