include $(ROOTDIR)/rules.mk

PKG_NAME:=pcre
PKG_VERSION:=8.45
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.sourceforge.net/project/pcre/pcre/$(PKG_VERSION)/
PKG_HASH:=4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-utf8 \
	--enable-unicode-properties \
	--disable-pcre16 \
	--disable-cpp \
	--disable-static \
	--enable-shared \
	--disable-stack-for-recursion \
	--disable-valgrind \
	--with-match-limit-recursion=16000

define update_pcre_config_prefix
	$(SED) 's,^prefix=.*,prefix=$(STAGING_DIR),;s,^exec_prefix=.*,exec_prefix=$(STAGING_DIR),' $(STAGING_DIR)/bin/pcre-config
endef

Hooks/Install/Post += update_pcre_config_prefix

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libpcre.so* $(ROMFSDIR)/lib/