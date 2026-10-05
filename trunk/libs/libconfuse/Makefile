include $(ROOTDIR)/rules.mk

PKG_NAME:=libconfuse
PKG_VERSION:=3.4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libconfuse/libconfuse/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=be97bf64ab8052ef874e6c2cfabd2dacf7ad76575bb12c7c42df3fd23675d151

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-examples

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libconfuse.so* $(ROMFSDIR)/lib/
