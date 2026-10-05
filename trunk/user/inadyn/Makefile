include $(ROOTDIR)/rules.mk

PKG_NAME:=inadyn
PKG_VERSION:=2.13.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/troglobit/inadyn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=07dbb25c37744ed0dc6a05938456d6e490e56a3229b720c994b8e633346d5c6d
PKG_FIXUP:=autoreconf
DEPENDS:=+confuse +libssl

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-openssl \
	--disable-static \
	--enable-shared

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/inadyn $(ROMFSDIR)/bin/inadyn
