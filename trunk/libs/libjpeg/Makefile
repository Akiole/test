include $(ROOTDIR)/rules.mk

PKG_NAME:=libjpeg-turbo
PKG_VERSION:=3.2.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libjpeg-turbo/libjpeg-turbo/tar.gz/$(PKG_VERSION)?
PKG_HASH:=980dd81f425082aa6d7c9e47fef27554ce7a9ffc8e2f6e863b97d263c5c50858

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DENABLE_STATIC=OFF \
	-DENABLE_SHARED=ON \
	-DWITH_JPEG8=ON \
	-DWITH_JPEG7=OFF \
	-DWITH_SIMD=OFF \
	-DENABLE_TESTING=OFF \
	-DENABLE_TOOLS=OFF

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libjpeg.so* $(ROMFSDIR)/lib/
