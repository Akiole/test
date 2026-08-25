include $(ROOTDIR)/rules.mk

PKG_NAME:=dropbear
PKG_VERSION:=2026.94
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SFTP),y)
TARGET_CFLAGS += -DSFTPSERVER_PATH=\\\"/usr/libexec/sftp-server\\\"
else
TARGET_CFLAGS += -DSFTPSERVER_PATH=\\\"/opt/libexec/sftp-server\\\"
endif
ifneq ($(CONFIG_FIRMWARE_INCLUDE_DROPBEAR_FAST_CODE),y)
TARGET_CFLAGS += -DDROPBEAR_SMALL_CODE
endif

CONFIGURE_ARGS += \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-loginfunc \
	--disable-pututline \
	--disable-pututxline \
	--disable-harden \
	--enable-zlib \
	--enable-bundled-libtom

MAKE_FLAGS += PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" MULTI=1

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dropbearmulti $(ROMFSDIR)/usr/bin/dropbearmulti
	$(INSTALL_BIN) ./sshd.sh $(ROMFSDIR)/usr/bin/sshd.sh
	$(LN) dropbearmulti $(ROMFSDIR)/usr/bin/ssh
	$(LN) dropbearmulti $(ROMFSDIR)/usr/bin/scp
	$(LN) dropbearmulti $(ROMFSDIR)/usr/bin/dropbearkey
	$(LN) dropbearmulti $(ROMFSDIR)/usr/bin/dropbearconvert
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(LN) ../bin/dropbearmulti $(ROMFSDIR)/usr/sbin/dropbear
