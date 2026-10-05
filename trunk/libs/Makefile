# =============================================================================
# Libraries Top-Level Makefile
# =============================================================================

.PHONY: all romfs clean

# Base paths
ifndef ROOTDIR
# Resolve to absolute path: a relative '..' would break when sub-makes
# (make -C <pkg>) inherit it, since their CWD is one level deeper.
ROOTDIR := $(abspath ..)
endif
export ROOTDIR
ifndef ROMFSDIR
ROMFSDIR = $(ROOTDIR)/romfs
endif
ifndef PROJECT_CONFIG
PROJECT_CONFIG = $(ROOTDIR)/.config
endif

UCLINUX_BUILD_LIB = 1
LIBS_BUILD_SHARED = y

-include $(LINUX_CONFIG)
include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)
include $(ROOTDIR)/host-tools.mk

CFLAGS  += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

dir_y =
ALL_LIB_DIRS := $(sort $(patsubst %/,%,$(wildcard */)))

# -----------------------------------------------------------------------------
# Library Switches (all default n, auto-enabled by features below)
# -----------------------------------------------------------------------------
LIBS_INCLUDE_BOOST         = n
LIBS_INCLUDE_LIBCARES      = n
LIBS_INCLUDE_LIBCURL       = n
LIBS_INCLUDE_LIBCAP_NG     = n
LIBS_INCLUDE_LIBEV         = n
LIBS_INCLUDE_LIBEVENT      = n
LIBS_INCLUDE_LIBICONV      = n
LIBS_INCLUDE_LIBJSON_C     = n
LIBS_INCLUDE_LIBUBOX       = n
LIBS_INCLUDE_LIBLZO        = n
LIBS_INCLUDE_LIBNCURSES    = n
LIBS_INCLUDE_LIBNGHTTP2    = n
LIBS_INCLUDE_LIBNL         = n
LIBS_INCLUDE_LIBPCAP       = n
LIBS_INCLUDE_LIBPCRE       = n
LIBS_INCLUDE_LIBUSB_0      = n
LIBS_INCLUDE_LIBUSB_1      = n
LIBS_INCLUDE_LIBRTLSDR     = n
LIBS_INCLUDE_LIBSODIUM     = n
LIBS_INCLUDE_LIBUDNS       = n
LIBS_INCLUDE_LIBUV         = n
LIBS_INCLUDE_LIBWEBSOCKETS = n
LIBS_INCLUDE_LIBXML2       = n
LIBS_INCLUDE_MBEDTLS       = n
LIBS_INCLUDE_LIBCONFUSE    = n
LIBS_INCLUDE_MEDIA         = n
LIBS_INCLUDE_READLINE      = n
LIBS_INCLUDE_LIBMNL        = n
LIBS_INCLUDE_LIBNFNETLINK  = n
LIBS_INCLUDE_LIBNETFILTER_QUEUE = n
LIBS_INCLUDE_OPENSSL       = n
LIBS_INCLUDE_ZLIB          = n
LIBS_INCLUDE_LIBTIRPC      = n
LIBS_INCLUDE_NETTLE        = n
LIBS_INCLUDE_GNUTLS        = n
LIBS_INCLUDE_GMP           = n

STORAGE_ENABLED = n

# -----------------------------------------------------------------------------
# Feature -> Library Mapping
# -----------------------------------------------------------------------------

# Core services (always built): skipdbv2 -> libev, miniupnpd -> openssl+libcap-ng
LIBS_INCLUDE_LIBEV    = y
LIBS_INCLUDE_OPENSSL  = y
LIBS_INCLUDE_LIBCAP_NG = y

# Storage
ifneq ($(filter y,$(CONFIG_BLK_DEV_SD) $(CONFIG_MMC_BLOCK)),)
STORAGE_ENABLED = y
endif

# Filesystems
ifeq ($(CONFIG_FIRMWARE_ENABLE_FAT),y)
LIBS_INCLUDE_LIBICONV = y
endif
ifeq ($(CONFIG_MTD_UBI),y)
LIBS_INCLUDE_LIBLZO = y
endif

# USB
ifdef CONFIG_USB_SUPPORT
LIBS_INCLUDE_LIBUSB_1 = y
LIBS_INCLUDE_LIBUBOX = y
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_DUMP1090) $(CONFIG_FIRMWARE_INCLUDE_RTL_SDR)),)
LIBS_INCLUDE_LIBRTLSDR = y
endif
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_U2EC),y)
LIBS_INCLUDE_LIBUSB_0 = y
endif

# Network tools
ifeq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
LIBS_INCLUDE_LIBMNL = y
endif
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_FAKEHTTP) $(CONFIG_FIRMWARE_INCLUDE_FAKESIP)),)
LIBS_INCLUDE_LIBNETFILTER_QUEUE = y
endif
ifeq ($(LIBS_INCLUDE_LIBNETFILTER_QUEUE),y)
LIBS_INCLUDE_LIBNFNETLINK = y
endif
ifeq ($(LIBS_INCLUDE_LIBNFNETLINK),y)
LIBS_INCLUDE_LIBMNL = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_WPA_SUPPLICANT),y)
LIBS_INCLUDE_LIBNL = y
endif

# VPN / proxy
ifeq ($(CONFIG_FIRMWARE_INCLUDE_N2N),y)
LIBS_INCLUDE_OPENSSL = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TMUX),y)
LIBS_INCLUDE_LIBEVENT  = y
LIBS_INCLUDE_LIBNCURSES = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_INADYN),y)
LIBS_INCLUDE_LIBCONFUSE = y
LIBS_INCLUDE_OPENSSL    = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_OPENVPN),y)
LIBS_INCLUDE_LIBLZO    = y
LIBS_INCLUDE_OPENSSL   = y
LIBS_INCLUDE_LIBCAP_NG = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SSWAN),y)
LIBS_INCLUDE_GMP = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_REDSOCKS),y)
LIBS_INCLUDE_LIBEVENT = y
endif
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS) $(CONFIG_FIRMWARE_INCLUDE_SSSERVER)),)
LIBS_INCLUDE_ZLIB      = y
LIBS_INCLUDE_LIBCARES  = y
LIBS_INCLUDE_LIBCURL   = y
LIBS_INCLUDE_LIBEV     = y
LIBS_INCLUDE_LIBPCRE   = y
LIBS_INCLUDE_LIBSODIUM = y
LIBS_INCLUDE_LIBUDNS   = y
LIBS_INCLUDE_MBEDTLS   = y
LIBS_INCLUDE_OPENSSL   = y
endif
ifneq ($(filter y,\
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CLIENT) \
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CMD) \
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_SERVER)),)
LIBS_INCLUDE_LIBICONV   = y
LIBS_INCLUDE_LIBNCURSES = y
LIBS_INCLUDE_READLINE   = y
LIBS_INCLUDE_OPENSSL    = y
LIBS_INCLUDE_ZLIB       = y
endif
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_WING) $(CONFIG_FIRMWARE_INCLUDE_TROJAN)),)
LIBS_INCLUDE_BOOST = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TTYD),y)
LIBS_INCLUDE_LIBJSON_C     = y
LIBS_INCLUDE_LIBWEBSOCKETS = y
LIBS_INCLUDE_LIBUV         = y
LIBS_INCLUDE_OPENSSL       = y
LIBS_INCLUDE_ZLIB          = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_ARIA),y)
LIBS_INCLUDE_LIBXML2   = y
LIBS_INCLUDE_LIBCURL   = y
LIBS_INCLUDE_LIBNGHTTP2 = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_xTUN),y)
LIBS_INCLUDE_LIBUV     = y
LIBS_INCLUDE_LIBSODIUM = y
endif

# Media
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FIREFLY),y)
LIBS_INCLUDE_LIBICONV = y
LIBS_INCLUDE_MEDIA    = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MINIDLNA),y)
LIBS_INCLUDE_LIBICONV = y
LIBS_INCLUDE_MEDIA    = y
endif

# Transmission (storage only)
ifeq ($(STORAGE_ENABLED),y)
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TRANSMISSION),y)
LIBS_INCLUDE_LIBCURL  = y
LIBS_INCLUDE_LIBEVENT = y
endif
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_CURL),y)
LIBS_INCLUDE_LIBCURL = y
LIBS_INCLUDE_OPENSSL = y
LIBS_INCLUDE_ZLIB    = y
endif

# NFS
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_NFSD) $(CONFIG_FIRMWARE_INCLUDE_NFSC)),)
LIBS_INCLUDE_LIBTIRPC = y
endif

# Terminal tools
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_HTOP) $(CONFIG_FIRMWARE_INCLUDE_NANO) $(CONFIG_FIRMWARE_INCLUDE_MTR)),)
LIBS_INCLUDE_LIBNCURSES = y
endif

# Tools needing iconv
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_LRZSZ) $(CONFIG_FIRMWARE_INCLUDE_PARTED) $(CONFIG_FIRMWARE_INCLUDE_MINIEAP)),)
LIBS_INCLUDE_LIBICONV = y
endif

# Packet capture
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_TCPDUMP) \
                  $(CONFIG_FIRMWARE_INCLUDE_NJIT_CLIENT) \
                  $(CONFIG_FIRMWARE_INCLUDE_MENTOHUST)),)
LIBS_INCLUDE_LIBPCAP = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MENTOHUST),y)
LIBS_INCLUDE_LIBICONV = y
endif

# -----------------------------------------------------------------------------
# Transitive deps (lib -> lib)
# -----------------------------------------------------------------------------
ifeq ($(LIBS_INCLUDE_OPENSSL),y)
LIBS_INCLUDE_ZLIB = y
endif
ifeq ($(LIBS_INCLUDE_MBEDTLS),y)
LIBS_INCLUDE_ZLIB = y
endif
ifeq ($(LIBS_INCLUDE_LIBCURL),y)
LIBS_INCLUDE_OPENSSL    = y
LIBS_INCLUDE_ZLIB       = y
LIBS_INCLUDE_LIBNGHTTP2 = y
endif
ifeq ($(LIBS_INCLUDE_LIBPCRE),y)
LIBS_INCLUDE_ZLIB = y
endif
ifeq ($(LIBS_INCLUDE_LIBRTLSDR),y)
LIBS_INCLUDE_LIBUSB_1 = y
endif
ifeq ($(LIBS_INCLUDE_LIBWEBSOCKETS),y)
LIBS_INCLUDE_LIBUV   = y
LIBS_INCLUDE_OPENSSL = y
LIBS_INCLUDE_ZLIB    = y
LIBS_INCLUDE_MBEDTLS = y
endif
ifeq ($(LIBS_INCLUDE_LIBXML2),y)
LIBS_INCLUDE_ZLIB     = y
LIBS_INCLUDE_LIBICONV = y
endif
ifeq ($(LIBS_INCLUDE_READLINE),y)
LIBS_INCLUDE_LIBNCURSES = y
endif

# -----------------------------------------------------------------------------
# Build dir collection (by dependency tier)
# -----------------------------------------------------------------------------

# Tier 1: no deps
ifeq ($(LIBS_INCLUDE_ZLIB),y)
dir_y += zlib
endif
ifeq ($(LIBS_INCLUDE_GMP),y)
dir_y += gmp
endif

# Tier 2: base libs only
ifeq ($(LIBS_INCLUDE_OPENSSL),y)
dir_y += libssl
endif
ifeq ($(LIBS_INCLUDE_LIBCONFUSE),y)
dir_y += libconfuse
endif
ifeq ($(LIBS_INCLUDE_LIBMNL),y)
dir_y += libmnl
endif
ifeq ($(LIBS_INCLUDE_LIBNFNETLINK),y)
dir_y += libnfnetlink
endif
ifeq ($(LIBS_INCLUDE_LIBNETFILTER_QUEUE),y)
dir_y += libnetfilter_queue
endif
ifeq ($(LIBS_INCLUDE_BOOST),y)
dir_y += boost
endif
ifeq ($(LIBS_INCLUDE_LIBCAP_NG),y)
dir_y += libcap-ng
endif
ifeq ($(LIBS_INCLUDE_LIBCARES),y)
dir_y += libcares
endif
ifeq ($(LIBS_INCLUDE_LIBEV),y)
dir_y += libev
endif
ifeq ($(LIBS_INCLUDE_LIBSODIUM),y)
dir_y += libsodium
endif
ifeq ($(LIBS_INCLUDE_LIBUDNS),y)
dir_y += libudns
endif
ifeq ($(LIBS_INCLUDE_LIBUV),y)
dir_y += libuv
endif
ifeq ($(LIBS_INCLUDE_LIBJSON_C),y)
dir_y += libjson-c
endif
ifeq ($(LIBS_INCLUDE_LIBUBOX),y)
dir_y += libubox
endif
ifeq ($(LIBS_INCLUDE_LIBLZO),y)
dir_y += liblzo
endif
ifeq ($(LIBS_INCLUDE_LIBICONV),y)
dir_y += libiconv
endif
ifeq ($(LIBS_INCLUDE_LIBNCURSES),y)
dir_y += libncurses
endif
ifeq ($(LIBS_INCLUDE_LIBNGHTTP2),y)
dir_y += libnghttp2
endif
ifeq ($(LIBS_INCLUDE_LIBNL),y)
dir_y += libnl
endif
ifeq ($(LIBS_INCLUDE_LIBPCAP),y)
dir_y += libpcap
endif
ifeq ($(LIBS_INCLUDE_LIBTIRPC),y)
dir_y += libtirpc
endif

# Tier 3: depends on Tier 2
ifeq ($(LIBS_INCLUDE_LIBCURL),y)
dir_y += libcurl
endif
ifeq ($(LIBS_INCLUDE_LIBEVENT),y)
dir_y += libevent
endif
ifeq ($(LIBS_INCLUDE_LIBPCRE),y)
dir_y += libpcre
dir_y += libpcre2
endif
ifeq ($(LIBS_INCLUDE_MBEDTLS),y)
dir_y += mbedtls
endif
ifeq ($(LIBS_INCLUDE_READLINE),y)
dir_y += readline
endif
ifeq ($(LIBS_INCLUDE_LIBXML2),y)
dir_y += libxml2
endif

# USB libs
ifeq ($(LIBS_INCLUDE_LIBUSB_1),y)
dir_y += libusb-1.0
endif
ifeq ($(LIBS_INCLUDE_LIBUSB_0),y)
dir_y += libusb
endif
ifeq ($(LIBS_INCLUDE_LIBRTLSDR),y)
dir_y += librtlsdr
endif

# Tier 4
ifeq ($(LIBS_INCLUDE_LIBWEBSOCKETS),y)
dir_y += libwebsockets
endif

# Tier 5: media
ifeq ($(LIBS_INCLUDE_MEDIA),y)
dir_y += libav libflac libid3tag libsqlite
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MINIDLNA),y)
dir_y += libexif libjpeg libogg libvorbis
endif

# -----------------------------------------------------------------------------
# Dedup & topological sort
# -----------------------------------------------------------------------------
dir_y := $(sort $(dir_y))

LIB_TIER1 := zlib
LIB_TIER2 := libssl libconfuse libmnl libnfnetlink boost libcap-ng libcares libev libsodium \
             libudns libuv libjson-c libubox liblzo libiconv libncurses libpcap libtirpc \
             libnghttp2 libnl libusb-1.0 libusb gmp
LIB_TIER3 := libcurl libevent libpcre libpcre2 mbedtls readline libxml2 \
             libnetfilter_queue librtlsdr
LIB_TIER4 := libwebsockets
LIB_TIER5 := libav libflac libid3tag libsqlite libexif libjpeg libogg libvorbis

dir_y := \
	$(filter $(LIB_TIER1),$(dir_y)) \
	$(filter $(LIB_TIER2),$(dir_y)) \
	$(filter $(LIB_TIER3),$(dir_y)) \
	$(filter $(LIB_TIER4),$(dir_y)) \
	$(filter $(LIB_TIER5),$(dir_y))

BUILD_TARGETS := $(patsubst %,%_only,$(dir_y))

# =============================================================================
# Targets
# =============================================================================
all: $(BUILD_TARGETS)
romfs: $(patsubst %,%_romfs,$(dir_y))
clean: $(patsubst %,%_clean,$(ALL_LIB_DIRS))

# =============================================================================
# Order-only deps (parallel safety)
# =============================================================================
ifneq ($(filter zlib_only,$(BUILD_TARGETS)),)
$(filter-out zlib_only,$(BUILD_TARGETS)): | zlib_only
endif
ifneq ($(filter libssl_only,$(BUILD_TARGETS)),)
libssl_only: | $(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libcurl_only,$(BUILD_TARGETS)),)
libcurl_only: | $(filter libssl_only,$(BUILD_TARGETS)) $(filter zlib_only,$(BUILD_TARGETS)) $(filter libnghttp2_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libevent_only,$(BUILD_TARGETS)),)
libevent_only: | $(filter libssl_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libpcre_only,$(BUILD_TARGETS)),)
libpcre_only: | $(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libpcre2_only,$(BUILD_TARGETS)),)
libpcre2_only: | $(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter mbedtls_only,$(BUILD_TARGETS)),)
mbedtls_only: | $(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter readline_only,$(BUILD_TARGETS)),)
readline_only: | $(filter libncurses_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libnfnetlink_only,$(BUILD_TARGETS)),)
libnfnetlink_only: | $(filter libmnl_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libnetfilter_queue_only,$(BUILD_TARGETS)),)
libnetfilter_queue_only: | $(filter libnfnetlink_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libxml2_only,$(BUILD_TARGETS)),)
libxml2_only: | $(filter zlib_only,$(BUILD_TARGETS)) $(filter libiconv_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libcares_only,$(BUILD_TARGETS)),)
libcares_only: | $(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter librtlsdr_only,$(BUILD_TARGETS)),)
librtlsdr_only: | $(filter libusb-1.0_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libusb_only,$(BUILD_TARGETS)),)
libusb_only: | $(filter libusb-1.0_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libwebsockets_only,$(BUILD_TARGETS)),)
libwebsockets_only: | \
	$(filter libuv_only,$(BUILD_TARGETS)) \
	$(filter libssl_only,$(BUILD_TARGETS)) \
	$(filter zlib_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libvorbis_only,$(BUILD_TARGETS)),)
libvorbis_only: | $(filter libogg_only,$(BUILD_TARGETS))
endif
ifneq ($(filter libav_only,$(BUILD_TARGETS)),)
libav_only: | $(filter libvorbis_only,$(BUILD_TARGETS)) $(filter libflac_only,$(BUILD_TARGETS))
endif

# =============================================================================
# Pattern rules
# =============================================================================
%_only:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m $(@:_only=) \033[0m"
	$(MAKE) -C $(@:_only=)
	@mkdir -p $(STAGEDIR)
	@echo "\033[1;30;42m $(@:_only=) \033[0m \033[1;30;44m Installing \033[0m"
	@if $(MAKE) -C $(@:_only=) install; then \
		touch $(STAGEDIR)/.installed_$(@:_only=); \
	else \
		echo "\033[1;30;41m $(@:_only=) \033[0m \033[1;30;41m install failed \033[0m"; \
		exit 1; \
	fi

%_romfs:
	@echo "\033[1;30;42m ROMFS \033[0m \033[1;30;44m $(@:_romfs=) \033[0m"
	$(MAKE) -C $(@:_romfs=) romfs

%_clean:
	@echo "\033[1;30;42m CLEAN \033[0m \033[1;30;44m $(@:_clean=) \033[0m"
	-$(MAKE) -C $(@:_clean=) clean
	rm -f $(STAGEDIR)/.installed_$(@:_clean=)
