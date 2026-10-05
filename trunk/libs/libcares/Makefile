include $(ROOTDIR)/rules.mk

PKG_NAME:=c-ares
PKG_VERSION:=1.34.8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/c-ares/c-ares/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=ddf8be8b179ef6ff656e7413da93cf0f3038c627aca29ce9aae30f66e5b32bc1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCARES_SHARED=ON \
	-DCARES_STATIC=OFF \
	-DCARES_BUILD_TESTS=OFF \
	-DCARES_BUILD_CONTAINER_TESTS=OFF \
	-DCARES_BUILD_TOOLS=OFF \
	-DCARES_BUILD_EXAMPLES=OFF \
	-DCARES_BUILD_DOCS=OFF \
	-DCARES_INSTALL=ON

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcares.so* $(ROMFSDIR)/lib/
