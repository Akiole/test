include $(ROOTDIR)/rules.mk

PKG_NAME:=pcre
PKG_VERSION:=8.45
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
	$(SED) 's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' $(STAGING_DIR)/bin/pcre-config
endef

Hooks/Install/Post += update_pcre_config_prefix

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libpcre.so* $(ROMFSDIR)/lib/