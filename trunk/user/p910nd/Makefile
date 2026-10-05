include $(ROOTDIR)/rules.mk

PKG_NAME:=p910nd
PKG_VERSION:=0.97
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kenyapcomau/p910nd/tar.gz/$(PKG_VERSION)?
PKG_HASH:=a1bcc2dd75bad4e00a9de5098dbd970e8380f978fc09292bcfa15852af6a6964

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/p910nd $(PKG_BUILD_DIR)/p910nd.c $(TARGET_LDFLAGS)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/p910nd /usr/sbin/p910nd
