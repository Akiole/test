include $(ROOTDIR)/rules.mk

PKG_NAME:=jq
PKG_VERSION:=1.8.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jqlang/jq/tar.gz/jq-$(PKG_VERSION)?
PKG_HASH:=188d03d029e8242a366d2286f07638924afe997120f6057e606f3c7a33984312
PKG_BUILD_DIR:=$(BUILD_DIR)/jq-jq-$(PKG_VERSION)

ONIG_VERSION:=6.9.10
ONIG_SOURCE:=oniguruma-$(ONIG_VERSION).tar.gz
ONIG_SOURCE_URL:=https://codeload.github.com/kkos/oniguruma/tar.gz/v$(ONIG_VERSION)?

include $(INCLUDE_DIR)/package.mk

# GitHub codeload tarballs do not include git submodules.
# Download oniguruma separately and place it in vendor/oniguruma/.
define Build/Prepare
	$(call Build/Prepare/Default)
	# Download and extract oniguruma submodule
	mkdir -p $(DL_DIR)
	@if [ ! -f $(DL_DIR)/$(ONIG_SOURCE) ]; then \
		echo "Downloading $(ONIG_SOURCE)..."; \
		curl -fL --connect-timeout 30 --retry 3 -o $(DL_DIR)/$(ONIG_SOURCE) "$(ONIG_SOURCE_URL)"; \
	fi
	rm -rf $(PKG_BUILD_DIR)/vendor/oniguruma
	mkdir -p $(PKG_BUILD_DIR)/vendor/oniguruma
	gzip -dc $(DL_DIR)/$(ONIG_SOURCE) | tar -C $(PKG_BUILD_DIR)/vendor/oniguruma --strip-components=1 -xf -
endef

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
