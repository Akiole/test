include $(ROOTDIR)/rules.mk

PKG_NAME:=natmap
PKG_VERSION:=20250924
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS = CROSS_PREFIX=$(TARGET_CROSS) ENABLE_STATIC=0

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(ROMFSDIR)/usr/bin/natmap
