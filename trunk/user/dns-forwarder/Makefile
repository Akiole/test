include $(ROOTDIR)/rules.mk

PKG_NAME:=dns-forwarder
PKG_VERSION:=1.2.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/aa65535/hev-dns-forwarder/tar.gz/refs/heads/master?
PKG_HASH:=02ffe6d177b47e6716aa41a0ff71fb6e052cd33e43d1ccfae7062d56608733e2
PKG_BUILD_DIR:=$(BUILD_DIR)/hev-dns-forwarder-master

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		CC=$(TARGET_CC)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/hev-dns-forwarder $(ROMFSDIR)/usr/bin/dns-forwarder
	$(INSTALL_BIN) ./dns-forwarder.sh $(ROMFSDIR)/usr/bin/dns-forwarder.sh
