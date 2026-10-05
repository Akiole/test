include $(ROOTDIR)/rules.mk

PKG_NAME:=libnfnetlink
PKG_VERSION:=1.0.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://netfilter.org/projects/libnfnetlink/files/
PKG_HASH:=b064c7c3d426efb4786e60a8e6859b82ee2f2c5e49ffeea640cfe4fe33cbc376

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libnfnetlink.so* $(ROMFSDIR)/lib/
