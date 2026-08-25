include $(ROOTDIR)/rules.mk

PKG_NAME:=openssh
PKG_VERSION:=10.4p1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -ffunction-sections -fdata-sections

CONFIGURE_ARGS += \
	--prefix=/usr \
	--sysconfdir=/etc/storage/openssh \
	--libexecdir=/usr/libexec \
	--with-pid-dir=/var/run \
	--with-privsep-path=/var/empty \
	--with-privsep-user=sshd \
	--with-sandbox=no \
	--without-pam \
	--without-selinux \
	--without-bsd-auth \
	--without-kerberos5 \
	--disable-strip \
	--disable-etc-default-login \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-libutil

CONFIGURE_VARS += \
	LD="$(TARGET_CC)"

# link with the compiler driver: openssh invokes $(LD) directly and the
# raw linker does not understand -Wl, driver flags

MAKE_FLAGS += LD="$(TARGET_CC)"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_OPENSSH),y)
	mkdir -p $(INSTALLDIR)/etc_ro/ssh
	$(ROMFSINST) $(PKG_BUILD_DIR)/moduli /etc_ro/ssh/moduli
	$(ROMFSINST) $(PKG_BUILD_DIR)/libssh.so /lib/libssh.so
	$(ROMFSINST) $(PKG_BUILD_DIR)/scp /usr/bin/scp
	$(ROMFSINST) $(PKG_BUILD_DIR)/ssh /usr/bin/ssh
	$(ROMFSINST) $(PKG_BUILD_DIR)/ssh-keygen /usr/bin/ssh-keygen
	$(ROMFSINST) $(PKG_BUILD_DIR)/sshd /usr/sbin/sshd
	$(ROMFSINST) -p +x /usr/bin/sshd.sh
endif
	mkdir -p $(INSTALLDIR)/usr/libexec
	$(ROMFSINST) $(PKG_BUILD_DIR)/sftp-server /usr/libexec/sftp-server
