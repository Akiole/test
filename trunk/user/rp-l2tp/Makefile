include $(ROOTDIR)/rules.mk

PKG_NAME:=rp-l2tp
PKG_VERSION:=0.5-rtn
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/themiron/rp-l2tp/tar.gz/refs/heads/master?
PKG_HASH:=87283eb02ac3cd1ebe6dd7044ca37f82d0d62348f06beab40f7493ebf1372495
PKG_BUILD_DIR:=$(BUILD_DIR)/rp-l2tp-master

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --sysconfdir=/etc

TARGET_CFLAGS += \
	-I$(KERNEL_HEADERS_PATH) \
	-DPPPOL2TP_V1

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/l2tpd $(ROMFSDIR)/usr/sbin/l2tpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/handlers/l2tp-control $(ROMFSDIR)/usr/sbin/l2tp-control
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/l2tp
	$(CP) $(PKG_BUILD_DIR)/handlers/cmd.so $(ROMFSDIR)/usr/lib/l2tp/
	$(CP) $(PKG_BUILD_DIR)/handlers/sync-pppd.so $(ROMFSDIR)/usr/lib/l2tp/
