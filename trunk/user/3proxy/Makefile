include $(ROOTDIR)/rules.mk

PKG_NAME:=3proxy
PKG_VERSION:=0.9.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CPPFLAGS += -D_GNU_SOURCE -DWITHSPLICE -DWITH_POLL -DWITH_NETFILTER -DNOODBC -DWITH_STD_MALLOC -DFD_SETSIZE=4096
TARGET_LDFLAGS += -pthread

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) -f Makefile.Linux \
		CC="$(TARGET_CC) -Wno-incompatible-pointer-types -Wno-implicit-function-declaration -Wno-int-conversion" \
		AR="$(TARGET_AR)" RANLIB="$(TARGET_RANLIB)" \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/3proxy $(ROMFSDIR)/usr/bin/3proxy
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/TransparentPlugin.ld.so $(ROMFSDIR)/usr/lib/TransparentPlugin.ld.so
