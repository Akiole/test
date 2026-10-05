include $(ROOTDIR)/rules.mk

PKG_NAME:=mentohust-1
PKG_VERSION:=1.0.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/HustLion/mentohust/tar.gz/master?
PKG_HASH:=3f7b969971e2821d30468487f94021454212f903c0267c7acec7c18d8ba85c22
PKG_BUILD_DIR:=$(BUILD_DIR)/mentohust-master
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--with-pcap=dylib \
	--disable-notify \
	--disable-encodepass

CONFIGURE_VARS += \
	am_cv_func_iconv=no

TARGET_LDFLAGS += -liconv

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mentohust $(ROMFSDIR)/usr/bin/bin_mentohust
	$(INSTALL_BIN) ./scripts/mentohust.sh $(ROMFSDIR)/usr/bin/mentohust.sh
