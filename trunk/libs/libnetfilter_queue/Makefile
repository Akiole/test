include $(ROOTDIR)/rules.mk

PKG_NAME:=libnetfilter_queue
PKG_VERSION:=1.0.5
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# pkg-config may not be installed on the host; pass dependency flags directly.
CONFIGURE_VARS += \
	LIBNFNETLINK_CFLAGS="-I$(STAGING_DIR)/include" \
	LIBNFNETLINK_LIBS="-L$(STAGING_DIR)/lib -lnfnetlink" \
	LIBMNL_CFLAGS="-I$(STAGING_DIR)/include" \
	LIBMNL_LIBS="-L$(STAGING_DIR)/lib -lmnl"

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libnetfilter_queue.so* $(ROMFSDIR)/lib/
