include $(ROOTDIR)/rules.mk

PKG_NAME:=simple-obfs
PKG_VERSION:=0.0.5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/shadowsocks/simple-obfs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0de9b551b67ec82d0af9d09bcb74c9e8d047f0082ae07db8e4f5f3defeb2ce4c
PKG_FIXUP:=autoreconf

# libcork is a git submodule not included in GitHub tarball
LIBCORK_VERSION:=29d7cbafc4b983192baeb0c962ab1ff591418f56
LIBCORK_SOURCE:=libcork-$(LIBCORK_VERSION).tar.gz
LIBCORK_SOURCE_URL:=https://codeload.github.com/shadowsocks/libcork/tar.gz/$(LIBCORK_VERSION)?
LIBCORK_HASH:=52be7bddaf4cbcf8635c616b69c1b89e776ad2b19458a3e8c80fc1c30b13f79d

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	$(call Build/Prepare/Default)
	# Download and extract libcork submodule
	mkdir -p $(DL_DIR)
	@if [ ! -f $(DL_DIR)/$(LIBCORK_SOURCE) ]; then \
		echo "Downloading $(LIBCORK_SOURCE)..."; \
		curl -fL --connect-timeout 30 --retry 3 -o $(DL_DIR)/$(LIBCORK_SOURCE) "$(LIBCORK_SOURCE_URL)"; \
	fi
	rm -rf $(PKG_BUILD_DIR)/libcork
	mkdir -p $(PKG_BUILD_DIR)/libcork
	gzip -dc $(DL_DIR)/$(LIBCORK_SOURCE) | tar -C $(PKG_BUILD_DIR)/libcork --strip-components=1 -xf -
endef

CONFIGURE_ARGS += \
	--prefix=/usr \
	--disable-ssp \
	--disable-assert \
	--disable-documentation

TARGET_CFLAGS += -I$(STAGING_DIR)/include -Wno-error=stringop-overread

CONFIGURE_VARS += \
	LIBS="-lpthread -lm"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/obfs-local $(ROMFSDIR)/usr/bin/obfs-local
