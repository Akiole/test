# ZeroTier One 1.14.0 - prebuilt mipsel binary for Padavan

include $(ROOTDIR)/rules.mk

PKG_NAME:=zerotier
PKG_VERSION:=1.14.0

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	@echo "Prebuilt binary package"
endef

define Build/Compile
	@echo "Nothing to compile"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) ./ZeroTierOne-1.14.0 $(ROMFSDIR)/usr/bin/zerotier-one
	$(INSTALL_BIN) ./zerotier.sh $(ROMFSDIR)/usr/bin/zerotier.sh
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-cli
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-idtool
