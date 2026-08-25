include $(ROOTDIR)/rules.mk

PKG_NAME:=dosfstools
PKG_VERSION:=4.2
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -ffunction-sections -fdata-sections -fvisibility=hidden

CONFIGURE_ARGS += \
	--enable-compat-symlinks \
	--exec-prefix=/ \
	--without-udev

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/src/fsck.fat /sbin/dosfsck
