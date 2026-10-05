include $(ROOTDIR)/rules.mk

PKG_NAME:=libnl
PKG_VERSION:=3.12.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/thom311/libnl/tar.gz/libnl3_12_0?
PKG_HASH:=a0dee52ff800a74cffbd02d64950ab7149a1df642dbdb4d601f66727b14ad021
PKG_BUILD_DIR:=$(BUILD_DIR)/libnl-libnl3_12_0

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-cli

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libnl-3.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libnl-genl-3.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libnl-route-3.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libnl-nf-3.so* $(ROMFSDIR)/lib/
