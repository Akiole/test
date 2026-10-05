include $(ROOTDIR)/rules.mk

PKG_NAME:=libcap-ng
PKG_VERSION:=0.9.6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/stevegrubb/libcap-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=399040138e0ca62fa2bcabd63da9af4431a246ef7a654561a0ca3cb00010a539

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--without-python3

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcap-ng.so* $(ROMFSDIR)/lib/