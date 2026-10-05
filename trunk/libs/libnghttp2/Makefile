include $(ROOTDIR)/rules.mk

PKG_NAME:=libnghttp2
PKG_VERSION:=1.70.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/nghttp2/nghttp2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d38d641fb3877b4847c774ad88b5f3ab70daf1ae0e616079bbeec4691186fc6a
PKG_BUILD_DIR:=$(BUILD_DIR)/nghttp2-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DENABLE_LIB_ONLY=ON \
	-DENABLE_SHARED_LIB=ON \
	-DENABLE_STATIC_LIB=OFF \
	-DENABLE_DOC=OFF \
	-DENABLE_EXAMPLES=OFF \
	-DENABLE_TESTS=OFF \
	-DENABLE_APP=OFF \
	-DENABLE_FAILMALLOC=OFF \
	-DENABLE_WERROR=OFF \
	-DENABLE_THREADS=ON \
	-DWITH_MRUBY=OFF \
	-DWITH_NEVERBLEED=OFF \
	-DWITH_LIBXML2=OFF \
	-DWITH_JEMALLOC=OFF \
	-DWITH_SYSTEMD=OFF \
	-DWITH_CUNIT=OFF

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/libnghttp2.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libnghttp2.so* $(ROMFSDIR)/lib/
