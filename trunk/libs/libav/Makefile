# FFmpeg/libav codec libraries
include $(ROOTDIR)/rules.mk

PKG_NAME:=libav
PKG_VERSION:=9.0
SRC_DIR:=./ffmpeg-9.x
PARAMS_CONFIG=--disable-swresample

include $(INCLUDE_DIR)/package.mk

PARSERS_CONFIG= \
	--enable-parser=aac \
	--enable-parser=ac3 \
	--enable-parser=mpegaudio

DEMUXERS_CONFIG= \
	--enable-demuxer=aac \
	--enable-demuxer=ac3 \
	--enable-demuxer=asf \
	--enable-demuxer=avi \
	--enable-demuxer=dts \
	--enable-demuxer=eac3 \
	--enable-demuxer=flac \
	--enable-demuxer=flv \
	--enable-demuxer=h264 \
	--enable-demuxer=matroska \
	--enable-demuxer=mov \
	--enable-demuxer=mp3 \
	--enable-demuxer=mpegps \
	--enable-demuxer=mpegts \
	--enable-demuxer=ogg \
	--enable-demuxer=wav

DECODERS_CONFIG=

ifeq ($(CONFIG_FIRMWARE_INCLUDE_FIREFLY),y)

DECODERS_CONFIG += \
	--enable-decoder=flac \
	--enable-decoder=alac

endif

PROTOCOLS_CONFIG:= \
	--enable-protocol=file

TARGET_CFLAGS += \
	-D_LFS64_LARGEFILE

CONFIGURE_ARGS = \
	--prefix=$(STAGING_DIR) \
	--cross-prefix=$(TARGET_CROSS) \
	--enable-cross-compile \
	--arch=$(ARCH) \
	--cpu=mips32r2 \
	--pkg-config=pkg-config \
	--target-os=linux \
	--cc="$(CC)" \
	--ld="$(CC)" \
	--as="$(AS)" \
	--enable-small \
	--enable-pthreads \
	--enable-gpl \
	--enable-zlib \
	--disable-doc \
	--disable-debug \
	--disable-avdevice \
	--disable-network \
	--disable-swscale \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-filters \
	--disable-encoders \
	--disable-muxers \
	--disable-bsfs \
	--disable-everything \
	$(PARAMS_CONFIG) \
	$(PROTOCOLS_CONFIG) \
	$(PARSERS_CONFIG) \
	$(DECODERS_CONFIG) \
	$(DEMUXERS_CONFIG) \
	$(if $(LIBS_BUILD_SHARED),--enable-shared --disable-static,--disable-shared --enable-static)

CONFIGURE_VARS += LD="$(CC)"
MAKE_FLAGS += LD="$(CC)"

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_FLAGS) \
		DESTDIR= \
		install
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(LIBS_BUILD_SHARED),y)
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libavcodec.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libavformat.so* $(ROMFSDIR)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libavutil.so* $(ROMFSDIR)/lib/
endif
