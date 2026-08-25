include $(ROOTDIR)/rules.mk

PKG_NAME:=udns
PKG_VERSION:=0.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += \
	-ffunction-sections \
	-fdata-sections \
	-fno-unwind-tables \
	-fno-asynchronous-unwind-tables

TARGET_LDFLAGS += \
	-Wl,--gc-sections

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
	)
	$(SED) 's|^all:.*|all: shared|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^LDSHARED = .*|LDSHARED = $(CC) -shared|' $(PKG_BUILD_DIR)/Makefile
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -fPIC" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		sharedlib
endef

define Build/Install
	$(INSTALL_DIR) $(STAGING_DIR)/include
	$(CP) $(PKG_BUILD_DIR)/udns.h $(STAGING_DIR)/include/
	$(INSTALL_DIR) $(STAGING_DIR)/lib
	$(CP) $(PKG_BUILD_DIR)/libudns.so.* $(STAGING_DIR)/lib/
	cd $(STAGING_DIR)/lib && ln -sf libudns.so.0 libudns.so
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_BUILD_DIR)/libudns.so* $(ROMFSDIR)/lib/
