# dump1090 Mode S/ADS-B decoder - bundled source with rtl-sdr support

include $(ROOTDIR)/rules.mk

PKG_NAME:=dump1090
PKG_VERSION:=efe64db
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/antirez/dump1090/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e3d0256d8867b0e8903eb901f9b6cd6dd508dde3a94f8a4c246f0ec9bb28158e

include $(INCLUDE_DIR)/package.mk

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/lib

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LDLIBS="-lrtlsdr -lusb-1.0 -lpthread -lm"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dump1090 $(ROMFSDIR)/usr/bin/dump1090
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/gmap.html $(ROMFSDIR)/usr/bin/gmap.html
	$(INSTALL_DIR) $(ROMFSDIR)/www
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tools/debug.html $(ROMFSDIR)/www/dump1090_debug.html
	ln -sf /tmp/frames.js $(ROMFSDIR)/www/frames.js
