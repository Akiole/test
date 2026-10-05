include $(ROOTDIR)/rules.mk

PKG_NAME:=flac
PKG_VERSION:=1.5.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xiph/flac/tar.gz/$(PKG_VERSION)?
PKG_HASH:=aea54ed186ad07a34750399cb27fc216a2b62d0ffcd6dc2e3064a3518c3146f8

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fPIC -Wno-inline

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

define flac_strip_winline
	@echo 'CFLAGS += -Wno-inline' >> $(PKG_BUILD_DIR)/src/libFLAC/Makefile
endef
Hooks/Configure/Post += flac_strip_winline

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(LIBS_BUILD_SHARED),y)
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libFLAC.so* $(ROMFSDIR)/lib/
endif