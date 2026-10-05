include $(ROOTDIR)/rules.mk

PKG_NAME:=libid3tag
PKG_VERSION:=0.15.2b

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/audacity/libid3tag/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1db8b1627b664e32094621efc1431a3471d760cc88800021e347302398ef5c6c

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fPIC

CONFIGURE_ARGS += \
	--disable-debugging \
	--disable-profiling \
	$(if $(LIBS_BUILD_SHARED),--disable-static,--enable-static) \
	$(if $(LIBS_BUILD_SHARED),--enable-shared,--disable-shared)

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(LIBS_BUILD_SHARED),y)
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libid3tag.so* $(ROMFSDIR)/lib/
endif