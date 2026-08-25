include $(ROOTDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_VERSION:=2026-07-21
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/msd_lite $(ROMFSDIR)/usr/bin/msd_lite
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_CONF) ./msd_lite.conf $(ROMFSDIR)/etc_ro/msd_lite.conf
