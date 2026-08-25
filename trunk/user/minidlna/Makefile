include $(ROOTDIR)/rules.mk

PKG_NAME:=minidlna
PKG_VERSION:=1.3.3
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I$(STAGING_DIR)/include -Wno-cpp
TARGET_LDFLAGS += -L$(STAGING_DIR)/lib

CONFIGURE_ARGS += \
	--disable-nls \
	--enable-tivo \
	--with-libiconv-prefix=$(STAGING_DIR) \
	--with-log-path=/mnt/minidlna \
	--with-db-path=/mnt/minidlna \
	--with-os-name="Linux" \
	--with-os-version="Linux/Cross_compiled" \
	--with-os-url="http://www.kernel.org/"

CONFIGURE_VARS += \
	ac_cv_lib_avformat_av_open_input_file=yes \
	LIBS="-ldl -lm -lpthread -lz -lexif -ljpeg -lsqlite3 -lid3tag -lFLAC -lvorbis -logg -lavformat -lavcodec -lavutil -liconv"

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minidlnad $(ROMFSDIR)/usr/bin/minidlnad
