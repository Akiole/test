include $(ROOTDIR)/rules.mk

PKG_NAME:=pcre2
PKG_VERSION:=10.44
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

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
