include $(ROOTDIR)/rules.mk

PKG_NAME:=socat
PKG_VERSION:=1.8.1.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-openssl \
	--disable-readline

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/socat $(ROMFSDIR)/usr/bin/socat
