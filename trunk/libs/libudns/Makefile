include $(ROOTDIR)/rules.mk

PKG_NAME:=udns
PKG_VERSION:=0.6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.corpit.ru/mjt/udns/
PKG_HASH:=696a2d0d518da985d975a65e11d166f3f57cdbd1d42376a0b85307f49601c6e8

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
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/lib
	$(CP) $(PKG_BUILD_DIR)/libudns.so.* $(PKG_INSTALL_DIR)/lib/
	cd $(PKG_INSTALL_DIR)/lib && ln -sf libudns.so.0 libudns.so
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/include
	$(CP) $(PKG_BUILD_DIR)/udns.h $(PKG_INSTALL_DIR)/include/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/include
	$(CP) $(PKG_BUILD_DIR)/udns.h $(1)/include/
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libudns.so* $(1)/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libudns.so* $(ROMFSDIR)/lib/
