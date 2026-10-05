include $(ROOTDIR)/rules.mk

PKG_NAME:=libuv
PKG_VERSION:=1.53.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libuv/libuv/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=279f3f67a24bb9921fe999ca6cd5e332fade8d515873ef9ba054b70e70a31d9e


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DLIBUV_BUILD_SHARED=ON \
	-DLIBUV_BUILD_STATIC=OFF \
	-DLIBUV_BUILD_TESTS=OFF \
	-DLIBUV_BUILD_BENCH=OFF

TARGET_CFLAGS += \
	-D_LARGEFILE_SOURCE

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/libuv.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libuv.so* $(ROMFSDIR)/lib/