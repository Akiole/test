include $(ROOTDIR)/rules.mk

PKG_NAME:=ipset
PKG_VERSION:=7.24
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--with-kmod=yes \
	--with-kbuild=$(ROOTDIR)/$(LINUXDIR)

EXTRA_LDFLAGS += -Wl,-rpath-link,$(STAGEDIR)/lib

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS) LDFLAGS= modules
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ipset $(ROMFSDIR)/sbin/ipset
