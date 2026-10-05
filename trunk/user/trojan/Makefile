include $(ROOTDIR)/rules.mk

PKG_NAME:=trojan
PKG_VERSION:=1.16.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/trojan-gfw/trojan/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=86cdb2685bb03a63b62ce06545c41189952f1ec4a0cd9147450312ed70956cbc

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
CMAKE_OPTIONS += \
	-DCMAKE_OSX_ARCHITECTURES= \
	-DBoost_USE_STATIC_LIBS=OFF \
	-DBoost_INCLUDE_DIR=$(STAGING_DIR)/include \
	-DBoost_LIBRARY_DIR=$(STAGING_DIR)/lib \
	-DENABLE_MYSQL=OFF \
	-DENABLE_REUSE_PORT=ON \
	-DSYSTEMD_SERVICE=OFF

TARGET_LDFLAGS += -Wl,--gc-sections

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trojan $(ROMFSDIR)/usr/bin/trojan
	$(INSTALL_DATA) ./cacert.pem $(ROMFSDIR)/usr/bin/cacert.pem
