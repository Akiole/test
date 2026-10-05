include $(ROOTDIR)/rules.mk

PKG_NAME:=mbedtls
PKG_VERSION:=2.28.10
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Mbed-TLS/mbedtls/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0f2e0525903a89ae1d39ce439d858be66933bda54c5b6102b72a29ed8fe7c088

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
	-DUSE_STATIC_MBEDTLS_LIBRARY=OFF \
	-DENABLE_TESTING=OFF \
	-DENABLE_PROGRAMS=OFF \
	-DLINK_WITH_PTHREAD=OFF \
	-DENABLE_ZLIB_SUPPORT=ON

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libmbedcrypto.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libmbedtls.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libmbedx509.so* $(ROMFSDIR)/lib/