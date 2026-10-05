include $(ROOTDIR)/rules.mk

PKG_NAME:=libexif
PKG_VERSION:=0.6.26
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libexif/libexif/tar.gz/libexif-0_6_26-release?
PKG_HASH:=974329442c4b0515814aa700073abbac592a29d1c2c14e4ec2bf0209764dabe9
PKG_BUILD_DIR:=$(BUILD_DIR)/libexif-libexif-0_6_26-release

PKG_FIXUP:=autoreconf
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-nls \
	--disable-docs \
	--disable-rpath

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libexif.so* $(ROMFSDIR)/lib/