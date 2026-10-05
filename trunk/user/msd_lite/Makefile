include $(ROOTDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_VERSION:=2026-07-21
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rozhuk-im/msd_lite/tar.gz/master?
PKG_HASH:=41bbefe7ab4f0a0ef914d5fc07c46973d69d501882749abdf029dfdea2015d73
PKG_BUILD_DIR:=$(BUILD_DIR)/msd_lite-master

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/msd_lite $(ROMFSDIR)/usr/bin/msd_lite
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_CONF) ./msd_lite.conf $(ROMFSDIR)/etc_ro/msd_lite.conf
