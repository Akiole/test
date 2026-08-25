include $(ROOTDIR)/rules.mk

PKG_NAME:=n2n
PKG_VERSION:=3.1.1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
