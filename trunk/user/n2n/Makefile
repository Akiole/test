include $(ROOTDIR)/rules.mk

PKG_NAME:=n2n
PKG_VERSION:=3.1.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ntop/n2n/tar.gz/$(PKG_VERSION)?
PKG_HASH:=311f89d147558ae4dfb0d8f8698f5429c05a3e19a9d25cb8c85bd73d02aff834

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += -DN2N_OPTION_USE_PTHREAD=ON
CMAKE_OPTIONS += -DN2N_OPTION_USE_OPENSSL=ON

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(TARGET_CROSS)strip $(PKG_BUILD_DIR)/supernode
	$(TARGET_CROSS)strip $(PKG_BUILD_DIR)/edge
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/supernode $(ROMFSDIR)/usr/bin/supernode
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/edge $(ROMFSDIR)/usr/bin/edge
