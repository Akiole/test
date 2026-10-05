include $(ROOTDIR)/rules.mk

PKG_NAME:=natmap
PKG_VERSION:=20260214
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/heiher/natmap/tar.gz/$(PKG_VERSION)?
PKG_HASH:=6dbe0dafff8cc6219c4ee733026f5b8f2fb63c8fd639b925bf851cd9a69f39a3

include $(INCLUDE_DIR)/package.mk

# GitHub tarball ships empty submodule placeholders that prevent patch(1)
# from creating new files.  Delete the placeholder before patches apply.
define Build/Prepare
	$(PKG_UNPACK)
	$(RM) -r $(PKG_BUILD_DIR)/third-part/hev-task-system
	$(Build/Patch)
endef

MAKE_FLAGS = CROSS_PREFIX=$(TARGET_CROSS) ENABLE_STATIC=0

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(ROMFSDIR)/usr/bin/natmap
