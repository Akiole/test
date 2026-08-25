include $(ROOTDIR)/rules.mk

PKG_NAME:=flac
PKG_VERSION:=1.5.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fPIC

CONFIGURE_ARGS += \
	$(if $(LIBS_BUILD_SHARED),--disable-static,--enable-static) \
	$(if $(LIBS_BUILD_SHARED),--enable-shared,--disable-shared) \
	--disable-cpplibs \
	--disable-examples \
	--disable-programs \
	--disable-doxygen-docs \
	--disable-ogg \
	--disable-debug \
	--disable-stack-smash-protection

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(LIBS_BUILD_SHARED),y)
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libFLAC.so* $(ROMFSDIR)/lib/
endif