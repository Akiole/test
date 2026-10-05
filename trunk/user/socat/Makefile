include $(ROOTDIR)/rules.mk

PKG_NAME:=socat
PKG_VERSION:=1.8.1.3
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dest-unreach.org/socat/download/
PKG_HASH:=06602ffd591e98c75b3dc1d66f0f19136cc666b0b2d95caad987d6ab2cb28097

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-openssl \
	--disable-readline

TARGET_CFLAGS += -D_GNU_SOURCE

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/socat $(ROMFSDIR)/usr/bin/socat
