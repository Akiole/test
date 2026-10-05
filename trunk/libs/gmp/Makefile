include $(ROOTDIR)/rules.mk

PKG_NAME:=gmp
PKG_VERSION:=6.3.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/gmp
PKG_HASH:=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-assembly \
	--disable-cxx \
	--disable-fat

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libgmp.so* $(ROMFSDIR)/lib/
