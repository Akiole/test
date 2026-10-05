include $(ROOTDIR)/rules.mk

PKG_NAME:=zerotier
PKG_VERSION:=1.16.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zerotier/ZeroTierOne/tar.gz/$(PKG_VERSION)?
PKG_HASH:=2c607f573c6e38815433af289d364a689a203b18b51125f06c4472014d0657f0
PKG_BUILD_DIR:=$(BUILD_DIR)/ZeroTierOne-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		LDLIBS="-latomic" \
		ZT_EMBEDDED=1 \
		ZT_SSO_SUPPORTED=0 \
		DEFS="" \
		OSTYPE="Linux" \
		one
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zerotier-one $(ROMFSDIR)/usr/bin/zerotier-one
	$(INSTALL_BIN) ./zerotier.sh $(ROMFSDIR)/usr/bin/zerotier.sh
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-cli
	ln -sf zerotier-one $(ROMFSDIR)/usr/bin/zerotier-idtool
