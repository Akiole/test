include $(ROOTDIR)/rules.mk

PKG_NAME:=libpcap
PKG_VERSION:=1.10.6
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--disable-static \
	--disable-yydebug \
	--disable-dbus \
	--disable-usb \
	--disable-bluetooth \
	--with-pcap=linux \
	--without-dag \
	--without-septel \
	--without-libnl

CONFIGURE_VARS += \
	ac_cv_netfilter_can_compile=no

define Build/Install
	$(call Build/Install/Default)
	rm -f $(STAGING_DIR)/lib/libpcap.a
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libpcap.so* $(ROMFSDIR)/lib/