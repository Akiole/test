include $(ROOTDIR)/rules.mk

PKG_NAME:=skipdbv2
PKG_VERSION:=1.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr

TARGET_LDFLAGS += -L$(STAGING_DIR)/lib -lev

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/skipd $(ROMFSDIR)/usr/sbin/skipd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/dbus $(ROMFSDIR)/usr/sbin/dbus
