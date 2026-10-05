include $(ROOTDIR)/rules.mk

PKG_NAME:=libiconv
PKG_VERSION:=1.19
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.gnu.org/pub/gnu/libiconv/
PKG_HASH:=88dd96a8c0464eca144fc791ae60cd31cd8ee78321e67397e25fc095c4a19aa6

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--enable-relocatable \
	--disable-nls \
	--disable-extra-encodings

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libiconv.so* $(ROMFSDIR)/lib/