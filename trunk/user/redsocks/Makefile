include $(ROOTDIR)/rules.mk

PKG_NAME:=redsocks
PKG_VERSION:=19b822e
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
