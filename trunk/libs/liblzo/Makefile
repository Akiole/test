include $(ROOTDIR)/rules.mk

PKG_NAME:=lzo
PKG_VERSION:=2.10
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.oberhumer.com/opensource/lzo/download/
PKG_HASH:=c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	$(if $(LIBS_BUILD_SHARED),--enable-shared,--disable-shared) \
	$(if $(LIBS_BUILD_SHARED),--disable-static,--enable-static) \
	--disable-dependency-tracking

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(LIBS_BUILD_SHARED),y)
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/liblzo2.so* $(ROMFSDIR)/lib/
endif