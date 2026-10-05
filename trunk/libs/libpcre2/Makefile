include $(ROOTDIR)/rules.mk

PKG_NAME:=pcre2
PKG_VERSION:=10.49
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(PKG_VERSION)/
PKG_HASH:=929f0b20e62879252a15886b06c89f1edef61a363cbd5826fb041080a5e557ae

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-utf8 \
	--enable-unicode-properties \
	--disable-pcre2-16 \
	--disable-pcre2-32 \
	--disable-cpp \
	--disable-static \
	--enable-shared \
	--disable-stack-for-recursion \
	--disable-valgrind \
	--with-match-limit-recursion=16000

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libpcre2-8.so* $(ROMFSDIR)/lib/
