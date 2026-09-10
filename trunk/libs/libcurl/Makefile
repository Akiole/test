include $(ROOTDIR)/rules.mk

PKG_NAME:=curl
PKG_VERSION:=8.21.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--enable-shared \
	--enable-ipv6 \
	--disable-ldap \
	--disable-rtsp \
	--disable-smb \
	--disable-telnet \
	--disable-tftp \
	--disable-dict \
	--disable-gopher \
	--disable-imap \
	--disable-pop3 \
	--disable-smtp \
	--disable-debug \
	--disable-docs \
	--without-libidn2 \
	--with-nghttp2 \
	--without-libssh2 \
	--without-libpsl \
	--without-zstd \
	--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
	--with-zlib=$(STAGING_DIR) \
	--with-openssl=$(STAGING_DIR)

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_CURL),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/curl $(ROMFSDIR)/usr/bin/
endif
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcurl.so* $(ROMFSDIR)/lib/