include $(ROOTDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.22
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/esnet/iperf/tar.gz/$(PKG_VERSION)?
PKG_HASH:=4dc1bc31ef4a4018973a6f543a3229fab020b20b26229bc7a40ed6779e367699
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -D_GNU_SOURCE

CONFIGURE_ARGS += \
	--disable-shared \
	--enable-static \
	--without-openssl

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/iperf3 $(ROMFSDIR)/usr/bin/iperf3
	$(INSTALL_BIN) ./iperf3.sh $(ROMFSDIR)/usr/bin/iperf3.sh
