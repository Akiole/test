include $(ROOTDIR)/rules.mk

PKG_NAME:=vlmcsd
PKG_VERSION:=svn1113
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) vlmcsd SAFE_MODE=1 CC=$(TARGET_CC_NOCACHE)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vlmcsd $(ROMFSDIR)/usr/bin/vlmcsd
	$(INSTALL_BIN) ./vlmcsd.sh $(ROMFSDIR)/usr/bin/vlmcsd.sh
