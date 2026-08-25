include $(ROOTDIR)/rules.mk

PKG_NAME:=mentohust-1
PKG_VERSION:=1.0.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
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
