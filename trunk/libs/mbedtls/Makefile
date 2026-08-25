include $(ROOTDIR)/rules.mk

PKG_NAME:=mbedtls
PKG_VERSION:=2.28.8
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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