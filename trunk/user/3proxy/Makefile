include $(ROOTDIR)/rules.mk

PKG_NAME:=3proxy
PKG_VERSION:=1.0.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/3proxy/3proxy/tar.gz/$(PKG_VERSION)?
PKG_HASH:=d339c75c6dba0928027e38b85b123e1720dbb2a0ccadeacbf75eddbef1cefed8

include $(INCLUDE_DIR)/package.mk

TARGET_CPPFLAGS += -D_GNU_SOURCE -DWITHSPLICE -DWITH_POLL -DWITH_NETFILTER -DNOODBC -DWITH_STD_MALLOC -DFD_SETSIZE=4096
TARGET_LDFLAGS += -pthread

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) -f Makefile.Linux \
		CC="$(TARGET_CC) -Wno-incompatible-pointer-types -Wno-implicit-function-declaration -Wno-int-conversion" \
		LN="$(TARGET_CC)" \
		AR="$(TARGET_AR)" RANLIB="$(TARGET_RANLIB)" \
		EXTRA_CFLAGS="$(TARGET_CPPFLAGS)" \
		EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		PLUGINS= \
		OPENSSL_CHECK=false \
		WOLFSSL_CHECK=false \
		PCRE_CHECK=false \
		PAM_CHECK=false
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/3proxy $(ROMFSDIR)/usr/bin/3proxy
