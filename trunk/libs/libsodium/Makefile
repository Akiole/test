include $(ROOTDIR)/rules.mk

PKG_NAME:=libsodium
PKG_VERSION:=1.0.22
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# configure probes thread_local before _Thread_local; on the mipsel-uclibc
# cross toolchain the probe passes but the real build flags make
# 'thread_local' an unknown type.  Force the C11 keyword _Thread_local,
# which GCC supports natively without any header.
CONFIGURE_VARS += ac_cv_tls=_Thread_local

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--disable-ssp \
	--disable-dependency-tracking \
	--disable-valgrind

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libsodium.so* $(ROMFSDIR)/lib/
