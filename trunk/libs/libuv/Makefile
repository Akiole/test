include $(ROOTDIR)/rules.mk

PKG_NAME:=libuv
PKG_VERSION:=1.52.1
SRC_DIR:=./$(PKG_NAME)-v$(PKG_VERSION)


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DLIBUV_BUILD_SHARED=ON \
	-DLIBUV_BUILD_STATIC=OFF \
	-DLIBUV_BUILD_TESTS=OFF \
	-DLIBUV_BUILD_BENCH=OFF

TARGET_CFLAGS += \
	-D_LARGEFILE_SOURCE \
	-D_LARGEFILE64_SOURCE

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/libuv.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libuv.so* $(ROMFSDIR)/lib/