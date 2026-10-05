include $(ROOTDIR)/rules.mk

PKG_NAME:=redsocks
PKG_VERSION:=19b822e
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/darkk/redsocks/tar.gz/$(PKG_VERSION)?
PKG_HASH:=aeadd6bca3d51ba73e2b31d8f50ba0ee0c1c991997c72850359413a49b9bd07b

include $(INCLUDE_DIR)/package.mk

TARGET_LDFLAGS += \
	-L$(STAGING_DIR)/usr/lib \
	-levent \
	-levent_core \
	-levent_extra

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/redsocks $(ROMFSDIR)/usr/bin/redsocks
	$(INSTALL_DIR) $(ROMFSDIR)/lib

#	$(ROMFSINST) -p +x $(THISDIR)/redsocks.sh /usr/bin/redsocks.sh
