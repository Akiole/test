include $(ROOTDIR)/rules.mk

PKG_NAME:=firefly
PKG_VERSION:=svn
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-iconv \
	--enable-mdns \
	--enable-ffmpeg \
	--enable-flac \
	--enable-sqlite3 \
	--with-sqlite3-includes=$(STAGING_DIR)/include \
	--with-sqlite3-libs=$(STAGING_DIR)/lib \
	--with-ffmpeg-includes=$(STAGING_DIR)/include \
	--with-ffmpeg-libs=$(STAGING_DIR)/lib \
	--with-id3tag=$(STAGING_DIR) \
	--with-libiconv-prefix=$(STAGING_DIR)

CONFIGURE_VARS += \
	ac_cv_func_setpgrp_void=yes \
	ac_cv_lib_FLAC_FLAC__metadata_chain_read=yes \
	LIBS="-liconv"

define Build/Prepare
	$(call Build/Prepare/Default)
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
