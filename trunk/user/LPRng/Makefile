include $(ROOTDIR)/rules.mk

PKG_NAME:=LPRng
PKG_VERSION:=3.8.B
PKG_JOBS:=-j1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -Wno-cpp -fcommon
TARGET_LDFLAGS += -lshared

CONFIGURE_ARGS += \
	--disable-ssl \
	--disable-kerberos_checks \
	--disable-nls \
	--disable-plugins \
	--disable-tcpwrappers \
	--with-spooldir=/var/spool/lpd \
	--with-lockfile=/var/run/lpd

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lpd $(ROMFSDIR)/usr/sbin/lpd
