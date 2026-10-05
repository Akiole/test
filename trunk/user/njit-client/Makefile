include $(ROOTDIR)/rules.mk

PKG_NAME:=njit8021xclient
PKG_VERSION:=1.3.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/liuqun/njit8021xclient/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9f61ca62b9bef3d2432b00dc66b35f367d9bb170df9c05029ca87df0f5c1fa14

include $(INCLUDE_DIR)/package.mk

# configure.ac lives in src/; run autoreconf + configure there manually

define Build/Configure
	(cd $(PKG_BUILD_DIR)/src; \
		autoreconf -fi; \
		$(CONFIGURE_VARS) \
		./configure \
			$(CONFIGURE_ARGS); \
	)
endef

CONFIGURE_PATH := src
MAKE_PATH := src
CONFIGURE_VARS += \
	ac_cv_path_PCAP_CONFIG=$(STAGING_DIR)/bin/pcap-config

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/client $(ROMFSDIR)/usr/bin/njit-client
