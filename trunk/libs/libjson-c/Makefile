include $(ROOTDIR)/rules.mk

PKG_NAME:=json-c
PKG_VERSION:=0.19
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/json-c/json-c/tar.gz/json-c-$(PKG_VERSION)?
PKG_HASH:=bf3955d1ee3da728d8e7b46ecc0e752c9cd7c93dee71e853f9ed300416d4c2c5
PKG_BUILD_DIR:=$(BUILD_DIR)/json-c-json-c-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_STATIC_LIBS=OFF \
	-DENABLE_RDRAND=OFF \
	-DENABLE_THREADING=ON \
	-DENABLE_TESTING=OFF \
	-DJSON_C_BUILD_TESTS=OFF \
	-DJSON_C_BUILD_EXAMPLES=OFF \
	-DJSON_C_INSTALL=ON \
	-DCMAKE_BUILD_TYPE=Release

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libjson-c.so* $(ROMFSDIR)/lib/