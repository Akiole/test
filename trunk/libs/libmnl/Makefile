include $(ROOTDIR)/rules.mk

PKG_NAME:=libmnl
PKG_VERSION:=1.0.5
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://netfilter.org/projects/libmnl/files/
PKG_HASH:=274b9b919ef3152bfb3da3a13c950dd60d6e2bcd54230ffeca298d03b40d0525

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libmnl.so* $(ROMFSDIR)/lib/
