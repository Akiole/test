include $(ROOTDIR)/rules.mk

PKG_NAME:=softethervpn
PKG_VERSION:=4.29.9680

PKG_SOURCE:=softether-src-v4.29-9680-rtm.tar.gz
PKG_SOURCE_URL:=https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/
PKG_HASH:=e6035fa7d9aaf59bdb342cd7ab5ecfdff89811a875f62a3230208cdc8a4e26e4
PKG_BUILD_DIR:=$(BUILD_DIR)/v4.29-9680

include $(INCLUDE_DIR)/package.mk

HAMCORE_DIR:=$(PKG_BUILD_DIR)/src/bin/BuiltHamcoreFiles/unix

# Source uses CRLF line endings; require binary patch mode
define Build/Patch
	@if [ -d "$(PATCH_DIR)" ]; then \
		for p in $(PATCH_DIR)/*.patch; do \
			[ -e "$$p" ] || continue; \
			echo "Applying $$p ..."; \
			patch --binary -d $(PKG_BUILD_DIR) -p1 < "$$p" || { echo "ERROR: Failed to apply $$p"; exit 1; }; \
		done; \
	fi
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	# Create build output directories
	mkdir -p $(PKG_BUILD_DIR)/tmp/objs/Mayaqua
	mkdir -p $(PKG_BUILD_DIR)/tmp/objs/Cedar
	mkdir -p $(PKG_BUILD_DIR)/tmp/as
	mkdir -p $(PKG_BUILD_DIR)/bin/vpnserver
	mkdir -p $(PKG_BUILD_DIR)/bin/vpnclient
	mkdir -p $(PKG_BUILD_DIR)/bin/vpnbridge
	mkdir -p $(PKG_BUILD_DIR)/bin/vpncmd
	# Copy prebuilt hamcore.se2
	mkdir -p $(HAMCORE_DIR)
	cp -f $(CURDIR)/hamcore-unix/v4.29-9680/hamcore.se2 $(HAMCORE_DIR)/hamcore.se2
	# Set far-future timestamp so make never tries to rebuild hamcore.se2
	# (hamcorebuilder is a target binary and cannot run on host)
	touch -t 203001010000 $(HAMCORE_DIR)/hamcore.se2
endef

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		-f src/makefiles/linux_32bit.mak \
		$(MAKE_FLAGS) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Build/Install
	# Install shared libraries to staging
	$(INSTALL_DIR) $(STAGEDIR)/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tmp/objs/Mayaqua/libMayaqua.so $(STAGEDIR)/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tmp/objs/Cedar/libCedar.so $(STAGEDIR)/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro/softethervpn
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CMD),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpncmd/vpncmd $(ROMFSDIR)/etc_ro/softethervpn/vpncmd
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CLIENT),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnclient/vpnclient $(ROMFSDIR)/etc_ro/softethervpn/vpnclient
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_SERVER),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vpnserver/vpnserver $(ROMFSDIR)/etc_ro/softethervpn/vpnserver
endif
	$(INSTALL_DATA) $(CURDIR)/hamcore-unix/v4.29-9680/hamcore.se2 $(ROMFSDIR)/etc_ro/softethervpn/hamcore.se2
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tmp/objs/Mayaqua/libMayaqua.so $(ROMFSDIR)/lib/libMayaqua.so
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tmp/objs/Cedar/libCedar.so $(ROMFSDIR)/lib/libCedar.so
	$(INSTALL_BIN) $(CURDIR)/softethervpn.sh $(ROMFSDIR)/usr/bin/softethervpn.sh
