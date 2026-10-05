include $(ROOTDIR)/rules.mk

PKG_NAME:=aria2
PKG_VERSION:=1.37.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/aria2/aria2/releases/download/release-$(PKG_VERSION)/
PKG_HASH:=8e7021c6d5e8f8240c9cc19482e0c8589540836747744724d86bf8af5a21f0e8

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fvisibility=hidden -Wno-cpp
TARGET_CXXFLAGS += -fvisibility-inlines-hidden -Wno-cpp
TARGET_LDFLAGS += -latomic

CONFIGURE_ARGS += \
	--disable-nls \
	--disable-xmltest \
	--disable-rpath \
	--without-libnettle \
	--without-libgmp \
	--without-libgcrypt \
	--without-libexpat \
	--without-libcares \
	--without-sqlite3 \
	--without-gnutls \
	--without-libssh2 \
	--without-gperftools \
	--without-libuv \
	--with-libz \
	--with-openssl \
	--with-libxml2 \
	--with-libnghttp2

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_ARIA_WEB_CONTROL),y)
	$(INSTALL_DIR) $(ROMFSDIR)/www/ariaweb
	unzip -qq $(wildcard ./*.zip) -d $(ROMFSDIR)/www/ariaweb
endif
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/aria2c $(ROMFSDIR)/usr/bin/aria2c
	$(INSTALL_BIN) ./aria.sh $(ROMFSDIR)/usr/bin/aria.sh
