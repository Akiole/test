include $(ROOTDIR)/rules.mk

PKG_NAME:=lzo
PKG_VERSION:=2.10
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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