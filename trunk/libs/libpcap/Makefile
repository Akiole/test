include $(ROOTDIR)/rules.mk

PKG_NAME:=libpcap
PKG_VERSION:=1.11.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.tcpdump.org/release/
PKG_HASH:=596389bc8560ea027dff9db8aaf6c173d992366d9aef4baf5d7c6d180b4d49ad

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