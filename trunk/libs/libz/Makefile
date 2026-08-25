include $(ROOTDIR)/rules.mk

PKG_NAME:=zlib
PKG_VERSION:=1.3.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--shared

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections

TARGET_LDFLAGS += \
	-Wl,--gc-sections

define Build/Configure
	$(call Build/Configure/Default)
	$(SED) 's|^AR=.*|AR=$(TARGET_AR)|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^ARFLAGS=.*|ARFLAGS=rcs|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^shared=.*|shared=1|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^LDSHARED=.*|LDSHARED=$(TARGET_CC) -shared -Wl,-soname,libz.so.1|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^SHAREDLIB=.*|SHAREDLIB=libz.so|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^SHAREDLIBV=.*|SHAREDLIBV=libz.so.1.3.2|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^SHAREDLIBM=.*|SHAREDLIBM=libz.so.1|' $(PKG_BUILD_DIR)/Makefile
endef

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/libz.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libz.so* $(ROMFSDIR)/lib/