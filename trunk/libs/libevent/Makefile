include $(ROOTDIR)/rules.mk

PKG_NAME:=libevent
PKG_VERSION:=2.1.13
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)-stable

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