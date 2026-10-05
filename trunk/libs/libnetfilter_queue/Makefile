include $(ROOTDIR)/rules.mk

PKG_NAME:=libnetfilter_queue
PKG_VERSION:=1.0.5
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://netfilter.org/projects/libnetfilter_queue/files/
PKG_HASH:=f9ff3c11305d6e03d81405957bdc11aea18e0d315c3e3f48da53a24ba251b9f5

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
