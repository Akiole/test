include $(ROOTDIR)/rules.mk

PKG_NAME:=jq
PKG_VERSION:=1.8.1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define JqPreConfigure
	(cd $(PKG_BUILD_DIR); \
	echo '#!/bin/sh' > scripts/version; \
	echo 'echo $(PKG_VERSION)' >> scripts/version; \
	chmod +x scripts/version; \
	autoreconf -i; \
	)
endef

Hooks/Configure/Pre += JqPreConfigure

CONFIGURE_ARGS += --with-oniguruma=builtin

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libjq.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_BUILD_DIR)/vendor/oniguruma/src/.libs/libonig.so* $(ROMFSDIR)/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/.libs/jq $(ROMFSDIR)/usr/bin/jq
