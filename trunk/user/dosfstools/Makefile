include $(ROOTDIR)/rules.mk

PKG_NAME:=dosfstools
PKG_VERSION:=4.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dosfstools/dosfstools/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=355a6725524b50e64ae94060ed28579e0e004c519fc964f7085188cd87a99ba7

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
