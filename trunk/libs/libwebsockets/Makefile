include $(ROOTDIR)/rules.mk

PKG_NAME:=libwebsockets
PKG_VERSION:=4.5.8
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=MinSizeRel \
	-DLWS_WITH_SHARED=ON \
	-DLWS_WITH_STATIC=OFF \
	-DLWS_WITH_SSL=ON \
	-DLWS_WITH_LIBUV=ON \
	-DLWS_WITHOUT_TESTAPPS=ON \
	-DLWS_WITHOUT_TEST_SERVER=ON \
	-DLWS_WITHOUT_TEST_CLIENT=ON \
	-DLWS_WITH_HTTP2=OFF \
	-DLWS_WITH_UDP=OFF \
	-DLWS_IPV6=ON

TARGET_CFLAGS += \
	-Wno-error=enum-int-mismatch

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libwebsockets.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libwebsockets-evlib_uv.so* $(ROMFSDIR)/lib/