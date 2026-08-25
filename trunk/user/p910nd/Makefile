include $(ROOTDIR)/rules.mk

PKG_NAME:=p910nd
PKG_VERSION:=0.97
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/p910nd $(PKG_BUILD_DIR)/p910nd.c $(TARGET_LDFLAGS)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/p910nd /usr/sbin/p910nd
