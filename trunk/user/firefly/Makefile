include $(ROOTDIR)/rules.mk

PKG_NAME:=firefly
PKG_VERSION:=svn
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# Vendored source (upstream SourceForge is no longer available)
PKG_SOURCE_URL:=file://$(CURDIR)
PKG_HASH:=919a53ca90e19971353000736639027c65578920cf4cac0c7bea0c709b273c75
PKG_BUILD_DIR:=$(BUILD_DIR)/mt-daapd-svn

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-iconv \
	--enable-mdns \
	--enable-ffmpeg \
	--enable-flac \
	--enable-sqlite3

CONFIGURE_VARS += \
	ac_cv_func_setpgrp_void=yes \
	ac_cv_lib_FLAC_FLAC__metadata_chain_read=yes \
	CPPFLAGS="$(CPPFLAGS) -I$(STAGING_DIR)/include" \
	LDFLAGS="$(LDFLAGS) -L$(STAGING_DIR)/lib" \
	LIBS="-lid3tag -lz -liconv -lavcodec -lavformat -lavutil"

# FFmpeg API compatibility fixes are applied via patches/100-ffmpeg-api-compat.patch
define Build/Prepare
	$(call Build/Prepare/Default)
	# Update config.sub/config.guess for modern host architectures (arm64)
	-cp /opt/homebrew/share/libtool/build-aux/config.sub $(PKG_BUILD_DIR)/config.sub 2>/dev/null
	-cp /opt/homebrew/share/libtool/build-aux/config.guess $(PKG_BUILD_DIR)/config.guess 2>/dev/null
	-cp /usr/share/libtool/build-aux/config.sub $(PKG_BUILD_DIR)/config.sub 2>/dev/null
	-cp /usr/share/libtool/build-aux/config.guess $(PKG_BUILD_DIR)/config.guess 2>/dev/null
	mkdir -p $(PKG_BUILD_DIR)/contrib/init.d
	touch $(PKG_BUILD_DIR)/contrib/init.d/Makefile.in
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/lib/mt-daapd
	$(INSTALL_DIR) $(ROMFSDIR)/usr/share/mt-daapd
	$(CP) $(PKG_BUILD_DIR)/admin-root/* $(ROMFSDIR)/usr/share/mt-daapd/
	$(CP) $(PKG_BUILD_DIR)/src/plugins/.libs/out-daap.so $(ROMFSDIR)/usr/lib/mt-daapd/
	$(CP) $(PKG_BUILD_DIR)/src/plugins/.libs/rsp.so $(ROMFSDIR)/usr/lib/mt-daapd/
	$(CP) $(PKG_BUILD_DIR)/src/plugins/.libs/ssc-ffmpeg.so $(ROMFSDIR)/usr/lib/mt-daapd/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mt-daapd $(ROMFSDIR)/usr/bin/mt-daapd
