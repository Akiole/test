include $(ROOTDIR)/rules.mk

PKG_NAME:=libevent
PKG_VERSION:=2.1.13
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/libevent/libevent/tar.gz/release-$(PKG_VERSION)-stable?
PKG_HASH:=1a0885e17dc78afbaeddf13cf849f9238bbc24acdc178464a0d1934d7c5ffbd5
PKG_BUILD_DIR:=$(BUILD_DIR)/libevent-release-2.1.13-stable

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--enable-thread-support \
	--disable-debug-mode \
	--disable-samples \
	--disable-libevent-regress \
	--enable-openssl \

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libevent*.so* $(ROMFSDIR)/lib/