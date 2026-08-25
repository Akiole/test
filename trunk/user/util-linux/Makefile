include $(ROOTDIR)/rules.mk

PKG_NAME:=util-linux
PKG_VERSION:=2.42.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--without-tinfo \
	--without-ncurses \
	--without-user \
	--without-cap-ng \
	--without-util \
	--without-ncursesw \
	--without-slang \
	--without-selinux \
	--without-audit \
	--without-udev \
	--without-python \
	--without-systemd \
	--without-btrfs \
	--without-readline \
	--enable-libblkid \
	--enable-blkid \
	--enable-libuuid \
	--disable-cal \
	--disable-fdformat \
	--disable-hwclock \
	--disable-static \
	--enable-shared \
	--disable-bfs \
	--disable-minix \
	--disable-ipcrm \
	--disable-ipcs \
	--disable-setterm \
	--disable-nsenter \
	--disable-rfkill \
	--disable-setpriv \
	--disable-logger \
	--disable-lslogins \
	--disable-runuser \
	--disable-libsmartcols \
	--disable-raw \
	--disable-ul \
	--disable-chfn-chsh \
	--disable-last \
	--disable-fdisks \
	--disable-libfdisk \
	--disable-zramctl \
	--disable-mesg \
	--disable-nologin \
	--disable-more \
	--disable-chmem \
	--disable-lsmem \
	--disable-bash-completion \
	--disable-nls \
	--disable-libmount \
	--disable-mount \
	--disable-losetup \
	--disable-fsck \
	--disable-partx \
	--disable-uuidd \
	--disable-mountpoint \
	--disable-fallocate \
	--disable-unshare \
	--disable-eject \
	--disable-agetty \
	--disable-cramfs \
	--disable-wdctl \
	--disable-switch_root \
	--disable-pivot_root \
	--disable-kill \
	--disable-utmpdump \
	--disable-rename \
	--disable-login \
	--disable-sulogin \
	--disable-su \
	--disable-schedutils \
	--disable-wall \
	--disable-use-tty-group \
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	--disable-year2038 \
	--disable-liblastlog2

CONFIGURE_VARS += scanf_cv_type_modifier=no \
	PATH="$(CONFIG_CROSS_COMPILER_ROOT)/bin:$(PATH)"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/blkid $(ROMFSDIR)/sbin/blkid
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libblkid.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libuuid.so* $(ROMFSDIR)/lib/
