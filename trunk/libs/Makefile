# =============================================================================
# Libraries Top-Level Makefile
# =============================================================================

.PHONY: all romfs clean

# -----------------------------------------------------------------------------
# Base Path Setup
# -----------------------------------------------------------------------------
ifndef ROOTDIR
ROOTDIR = ..
endif

ifndef ROMFSDIR
ROMFSDIR = $(ROOTDIR)/build/romfs
endif

ifndef PROJECT_CONFIG
PROJECT_CONFIG = $(ROOTDIR)/.config
endif

# Used by vendors/config/mips/config.arch to conditionally set stage path CFLAGS/LDFLAGS
UCLINUX_BUILD_LIB = 1

# Build all as shared libraries; affects libav/libflac/libid3tag/liblzo etc.
LIBS_BUILD_SHARED = y

-include $(LINUX_CONFIG)
include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)
include $(ROOTDIR)/host-tools.mk

# Global optimization: discard unused functions and data sections
CFLAGS  += -ffunction-sections -fdata-sections
LDFLAGS += -Wl,--gc-sections

DESTDIR = $(STAGEDIR)

# -----------------------------------------------------------------------------
# External Config Variable Defaults
# -----------------------------------------------------------------------------
CONFIG_FIRMWARE_ENABLE_FAT            ?= n
CONFIG_FIRMWARE_ENABLE_EXFAT          ?= n
CONFIG_FIRMWARE_INCLUDE_ANTFS         ?= n
CONFIG_FIRMWARE_INCLUDE_ARIA          ?= n
CONFIG_FIRMWARE_INCLUDE_CURL          ?= n
CONFIG_FIRMWARE_INCLUDE_DUMP1090      ?= n
CONFIG_FIRMWARE_INCLUDE_FIREFLY       ?= n
CONFIG_FIRMWARE_INCLUDE_HTOP          ?= n
CONFIG_FIRMWARE_INCLUDE_INADYN        ?= n
CONFIG_FIRMWARE_INCLUDE_IPSET         ?= n
CONFIG_FIRMWARE_INCLUDE_LRZSZ         ?= n
CONFIG_FIRMWARE_INCLUDE_MENTOHUST     ?= n
CONFIG_FIRMWARE_INCLUDE_MINIDLNA      ?= n
CONFIG_FIRMWARE_INCLUDE_MINIEAP       ?= n
CONFIG_FIRMWARE_INCLUDE_MTR           ?= n
CONFIG_FIRMWARE_INCLUDE_NANO          ?= n
CONFIG_FIRMWARE_INCLUDE_NFSC          ?= n
CONFIG_FIRMWARE_INCLUDE_NFSD          ?= n
CONFIG_FIRMWARE_INCLUDE_NJIT_CLIENT   ?= n
CONFIG_FIRMWARE_INCLUDE_OPENVPN       ?= n
CONFIG_FIRMWARE_INCLUDE_PARTED        ?= n
CONFIG_FIRMWARE_INCLUDE_REDSOCKS      ?= n
CONFIG_FIRMWARE_INCLUDE_RTL_SDR       ?= n
CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS   ?= n
CONFIG_FIRMWARE_INCLUDE_SSSERVER      ?= n
CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CLIENT ?= n
CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CMD    ?= n
CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_SERVER ?= n
CONFIG_FIRMWARE_INCLUDE_SMBD          ?= n
CONFIG_FIRMWARE_INCLUDE_SMBD_SYSLOG   ?= n
CONFIG_FIRMWARE_INCLUDE_WINS          ?= n
CONFIG_FIRMWARE_INCLUDE_TCPDUMP       ?= n
CONFIG_FIRMWARE_INCLUDE_TRANSMISSION  ?= n
CONFIG_FIRMWARE_INCLUDE_TROJAN        ?= n
CONFIG_FIRMWARE_INCLUDE_TTYD          ?= n
CONFIG_FIRMWARE_INCLUDE_U2EC          ?= n
CONFIG_FIRMWARE_INCLUDE_WING          ?= n
CONFIG_FIRMWARE_INCLUDE_xTUN          ?= n

# -----------------------------------------------------------------------------
# Dynamic Build Directory Collector
# -----------------------------------------------------------------------------
dir_y =

# All library subdirs (for clean, ensures disabled libs are also cleaned)
ALL_LIB_DIRS := $(sort $(patsubst %/,%,$(wildcard */)))

# -----------------------------------------------------------------------------
# Library Switches (all disabled by default)
# -----------------------------------------------------------------------------
LIBS_INCLUDE_BOOST         = n
LIBS_INCLUDE_LIBCARES      = n
LIBS_INCLUDE_LIBCURL       = n
LIBS_INCLUDE_LIBCAP_NG     = n
LIBS_INCLUDE_LIBEV         = n
LIBS_INCLUDE_LIBEVENT      = n
LIBS_INCLUDE_LIBICONV      = n
LIBS_INCLUDE_LIBJSON_C     = n
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

STORAGE_ENABLED = n

# -----------------------------------------------------------------------------
# Feature -> Library Switch Mapping (grouped by feature, includes transitive deps)
# -----------------------------------------------------------------------------

# --- Storage Support ---
ifneq ($(filter y,$(CONFIG_BLK_DEV_SD) $(CONFIG_MMC_BLOCK)),)
STORAGE_ENABLED = y
endif

# --- Filesystems ---
ifeq ($(CONFIG_FIRMWARE_ENABLE_FAT),y)
LIBS_INCLUDE_LIBICONV = y
endif
ifeq ($(CONFIG_MTD_UBI),y)
LIBS_INCLUDE_LIBLZO = y
endif

# --- USB Support ---
ifeq ($(CONFIG_USB_SUPPORT),y)
LIBS_INCLUDE_LIBUSB_1 = y
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_DUMP1090) $(CONFIG_FIRMWARE_INCLUDE_RTL_SDR)),)
LIBS_INCLUDE_LIBRTLSDR = y
LIBS_INCLUDE_LIBUSB_1  = y
endif
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_U2EC),y)
LIBS_INCLUDE_LIBUSB_0 = y
endif

# --- Network Tools ---
# IPSET: requires libmnl
ifeq ($(CONFIG_FIRMWARE_INCLUDE_IPSET),y)
LIBS_INCLUDE_LIBMNL = y
endif

# fakehttp / fakesip: requires libnetfilter_queue(->libnfnetlink->libmnl)
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_FAKEHTTP) $(CONFIG_FIRMWARE_INCLUDE_FAKESIP)),)
LIBS_INCLUDE_LIBNETFILTER_QUEUE = y
endif

# libnetfilter_queue -> libnfnetlink -> libmnl
ifeq ($(LIBS_INCLUDE_LIBNETFILTER_QUEUE),y)
LIBS_INCLUDE_LIBNFNETLINK = y
endif
ifeq ($(LIBS_INCLUDE_LIBNFNETLINK),y)
LIBS_INCLUDE_LIBMNL = y
endif

# wpa_supplicant (nl80211 WiFi driver): requires libnl-3
ifeq ($(CONFIG_FIRMWARE_INCLUDE_WPA_SUPPLICANT),y)
LIBS_INCLUDE_LIBNL = y
endif

# n2n: requires openssl(->zlib)
ifeq ($(CONFIG_FIRMWARE_INCLUDE_N2N),y)
LIBS_INCLUDE_OPENSSL = y
endif

# tmux: requires libevent + ncurses
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TMUX),y)
LIBS_INCLUDE_LIBEVENT  = y
LIBS_INCLUDE_LIBNCURSES = y
endif

# inadyn: requires confuse + openssl(->zlib)
ifeq ($(CONFIG_FIRMWARE_INCLUDE_INADYN),y)
LIBS_INCLUDE_LIBCONFUSE = y
LIBS_INCLUDE_OPENSSL    = y
endif

# OpenVPN: requires lzo + openssl(->zlib) + libcap-ng
ifeq ($(CONFIG_FIRMWARE_INCLUDE_OPENVPN),y)
LIBS_INCLUDE_LIBLZO    = y
LIBS_INCLUDE_OPENSSL   = y
LIBS_INCLUDE_LIBCAP_NG = y
endif

# redsocks: requires libevent
ifeq ($(CONFIG_FIRMWARE_INCLUDE_REDSOCKS),y)
LIBS_INCLUDE_LIBEVENT = y
endif

# Shadowsocks/SSServer: requires cares + curl(->openssl,zlib) + ev + pcre(->zlib)
#                       + sodium + udns + mbedtls(->zlib) + openssl(->zlib) + zlib
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

# SoftEther VPN: requires iconv + ncurses + readline(->ncurses) + openssl(->zlib) + zlib
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

# Trojan/Wing: requires boost
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_WING) $(CONFIG_FIRMWARE_INCLUDE_TROJAN)),)
LIBS_INCLUDE_BOOST = y
endif

# ttyd: requires json-c + websockets(->libuv,openssl,zlib) + libuv + openssl(->zlib) + zlib
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TTYD),y)
LIBS_INCLUDE_LIBJSON_C     = y
LIBS_INCLUDE_LIBWEBSOCKETS = y
LIBS_INCLUDE_LIBUV         = y
LIBS_INCLUDE_OPENSSL       = y
LIBS_INCLUDE_ZLIB          = y
endif

# aria2: requires xml2(->zlib,iconv) + curl(->openssl,zlib) + nghttp2(HTTP/2)
ifeq ($(CONFIG_FIRMWARE_INCLUDE_ARIA),y)
LIBS_INCLUDE_LIBXML2  = y
LIBS_INCLUDE_LIBCURL  = y
LIBS_INCLUDE_LIBNGHTTP2 = y
endif

# --- Media Services ---
ifeq ($(CONFIG_FIRMWARE_INCLUDE_FIREFLY),y)
LIBS_INCLUDE_LIBICONV = y
LIBS_INCLUDE_MEDIA    = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MINIDLNA),y)
LIBS_INCLUDE_LIBICONV = y
LIBS_INCLUDE_MEDIA    = y
endif

# transmission: requires curl(->openssl,zlib) + event (storage only)
ifeq ($(STORAGE_ENABLED),y)
  ifeq ($(CONFIG_FIRMWARE_INCLUDE_TRANSMISSION),y)
    LIBS_INCLUDE_LIBCURL  = y
    LIBS_INCLUDE_LIBEVENT = y
  endif
endif

# curl tool: requires curl(->openssl,zlib)
ifeq ($(CONFIG_FIRMWARE_INCLUDE_CURL),y)
LIBS_INCLUDE_LIBCURL = y
LIBS_INCLUDE_OPENSSL = y
LIBS_INCLUDE_ZLIB    = y
endif

# --- NFS Support ---
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_NFSD) $(CONFIG_FIRMWARE_INCLUDE_NFSC)),)
LIBS_INCLUDE_LIBTIRPC = y
endif

# xTun: requires libuv + sodium
ifeq ($(CONFIG_FIRMWARE_INCLUDE_xTUN),y)
LIBS_INCLUDE_LIBUV     = y
LIBS_INCLUDE_LIBSODIUM = y
endif

# --- Terminal Tools ---
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_HTOP) $(CONFIG_FIRMWARE_INCLUDE_NANO) $(CONFIG_FIRMWARE_INCLUDE_MTR)),)
LIBS_INCLUDE_LIBNCURSES = y
endif

# --- Other tools requiring iconv ---
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_LRZSZ) $(CONFIG_FIRMWARE_INCLUDE_PARTED) $(CONFIG_FIRMWARE_INCLUDE_MINIEAP)),)
LIBS_INCLUDE_LIBICONV = y
endif

# --- Packet Capture Tools ---
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_TCPDUMP) \
                  $(CONFIG_FIRMWARE_INCLUDE_NJIT_CLIENT) \
                  $(CONFIG_FIRMWARE_INCLUDE_MENTOHUST)),)
LIBS_INCLUDE_LIBPCAP = y
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MENTOHUST),y)
LIBS_INCLUDE_LIBICONV = y
endif

# -----------------------------------------------------------------------------
# Auto-enable Transitive Dependencies (lib -> lib)
# -----------------------------------------------------------------------------

# openssl -> zlib
ifeq ($(LIBS_INCLUDE_OPENSSL),y)
LIBS_INCLUDE_ZLIB = y
endif

# mbedtls -> zlib
ifeq ($(LIBS_INCLUDE_MBEDTLS),y)
LIBS_INCLUDE_ZLIB = y
endif

# libcurl -> openssl + zlib + nghttp2(HTTP/2)
ifeq ($(LIBS_INCLUDE_LIBCURL),y)
LIBS_INCLUDE_OPENSSL   = y
LIBS_INCLUDE_ZLIB      = y
LIBS_INCLUDE_LIBNGHTTP2 = y
endif

# libpcre -> zlib
ifeq ($(LIBS_INCLUDE_LIBPCRE),y)
LIBS_INCLUDE_ZLIB = y
endif

# librtlsdr -> libusb-1.0
ifeq ($(LIBS_INCLUDE_LIBRTLSDR),y)
LIBS_INCLUDE_LIBUSB_1 = y
endif

# libwebsockets -> libuv + openssl + zlib
ifeq ($(LIBS_INCLUDE_LIBWEBSOCKETS),y)
LIBS_INCLUDE_LIBUV   = y
LIBS_INCLUDE_OPENSSL = y
LIBS_INCLUDE_ZLIB    = y
endif

# libxml2 -> zlib + libiconv
ifeq ($(LIBS_INCLUDE_LIBXML2),y)
LIBS_INCLUDE_ZLIB     = y
LIBS_INCLUDE_LIBICONV = y
endif

# readline -> libncurses
ifeq ($(LIBS_INCLUDE_READLINE),y)
LIBS_INCLUDE_LIBNCURSES = y
endif

# -----------------------------------------------------------------------------
# Dynamic Build Directory Collection (append all here)
# -----------------------------------------------------------------------------

# --- Base Libraries (Tier 1: no deps) ---
ifeq ($(LIBS_INCLUDE_ZLIB),y)
dir_y += libz
endif

# --- Tier 2: depends only on base libs ---
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

# --- Tier 3: depends on Tier 2 ---
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

# --- USB Libraries ---
ifeq ($(LIBS_INCLUDE_LIBUSB_0),y)
dir_y += libusb
endif
ifeq ($(LIBS_INCLUDE_LIBUSB_1),y)
dir_y += libusb-1.0
endif
ifeq ($(LIBS_INCLUDE_LIBRTLSDR),y)
dir_y += librtlsdr
endif

# --- Tier 4: depends on Tier 3 ---
ifeq ($(LIBS_INCLUDE_LIBWEBSOCKETS),y)
dir_y += libwebsockets
endif

# --- Media-related (Tier 5: multi-tier deps) ---
ifeq ($(LIBS_INCLUDE_MEDIA),y)
dir_y += libav libflac libid3tag libsqlite
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MINIDLNA),y)
dir_y += libexif libjpeg libogg libvorbis
endif

# -----------------------------------------------------------------------------
# Dedup & Topological Sort (ordered by dependency tier; exact deps enforced by order-only below)
# -----------------------------------------------------------------------------
dir_y := $(sort $(dir_y))

# Reorder by dependency tier (base libs first, higher tiers last)
LIB_TIER1 := libz
LIB_TIER2 := libssl libconfuse libmnl libnfnetlink boost libcap-ng libcares libev libsodium \
             libudns libuv libjson-c liblzo libiconv libncurses libpcap libtirpc \
             libnghttp2 libnl \
             libusb libusb-1.0
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
# Target Definitions
# =============================================================================
all: $(BUILD_TARGETS)

romfs: $(patsubst %,%_romfs,$(dir_y))

clean: $(patsubst %,%_clean,$(ALL_LIB_DIRS))

# =============================================================================
# Dynamic Dependency Declarations (order-only, ensures parallel safety)
# =============================================================================

# libz is the base library; all others wait for it
ifneq ($(filter libz_only,$(BUILD_TARGETS)),)
$(filter-out libz_only,$(BUILD_TARGETS)): | libz_only
endif

# libssl -> libz
ifneq ($(filter libssl_only,$(BUILD_TARGETS)),)
libssl_only: | $(filter libz_only,$(BUILD_TARGETS))
endif

# libcurl -> libssl + libz + libnghttp2
ifneq ($(filter libcurl_only,$(BUILD_TARGETS)),)
libcurl_only: | $(filter libssl_only,$(BUILD_TARGETS)) $(filter libz_only,$(BUILD_TARGETS)) $(filter libnghttp2_only,$(BUILD_TARGETS))
endif

# libevent -> libssl
ifneq ($(filter libevent_only,$(BUILD_TARGETS)),)
libevent_only: | $(filter libssl_only,$(BUILD_TARGETS))
endif

# libpcre -> libz
ifneq ($(filter libpcre_only,$(BUILD_TARGETS)),)
libpcre_only: | $(filter libz_only,$(BUILD_TARGETS))
endif

# libpcre2 -> libz
ifneq ($(filter libpcre2_only,$(BUILD_TARGETS)),)
libpcre2_only: | $(filter libz_only,$(BUILD_TARGETS))
endif

# mbedtls -> libz
ifneq ($(filter mbedtls_only,$(BUILD_TARGETS)),)
mbedtls_only: | $(filter libz_only,$(BUILD_TARGETS))
endif

# readline -> libncurses
ifneq ($(filter readline_only,$(BUILD_TARGETS)),)
readline_only: | $(filter libncurses_only,$(BUILD_TARGETS))
endif

# libnfnetlink -> libmnl
ifneq ($(filter libnfnetlink_only,$(BUILD_TARGETS)),)
libnfnetlink_only: | $(filter libmnl_only,$(BUILD_TARGETS))
endif

# libnetfilter_queue -> libnfnetlink
ifneq ($(filter libnetfilter_queue_only,$(BUILD_TARGETS)),)
libnetfilter_queue_only: | $(filter libnfnetlink_only,$(BUILD_TARGETS))
endif

# libxml2 -> libz + libiconv
ifneq ($(filter libxml2_only,$(BUILD_TARGETS)),)
libxml2_only: | $(filter libz_only,$(BUILD_TARGETS)) $(filter libiconv_only,$(BUILD_TARGETS))
endif

# libcares -> libz
ifneq ($(filter libcares_only,$(BUILD_TARGETS)),)
libcares_only: | $(filter libz_only,$(BUILD_TARGETS))
endif

# librtlsdr -> libusb-1.0
ifneq ($(filter librtlsdr_only,$(BUILD_TARGETS)),)
librtlsdr_only: | $(filter libusb-1.0_only,$(BUILD_TARGETS))
endif

# libwebsockets -> libuv + libssl + libz
ifneq ($(filter libwebsockets_only,$(BUILD_TARGETS)),)
libwebsockets_only: | \
	$(filter libuv_only,$(BUILD_TARGETS)) \
	$(filter libssl_only,$(BUILD_TARGETS)) \
	$(filter libz_only,$(BUILD_TARGETS))
endif

# libvorbis -> libogg
ifneq ($(filter libvorbis_only,$(BUILD_TARGETS)),)
libvorbis_only: | $(filter libogg_only,$(BUILD_TARGETS))
endif

# libav -> libvorbis + libflac
ifneq ($(filter libav_only,$(BUILD_TARGETS)),)
libav_only: | $(filter libvorbis_only,$(BUILD_TARGETS)) $(filter libflac_only,$(BUILD_TARGETS))
endif

# =============================================================================
# Pattern Rules
# =============================================================================

%_only:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m $(@:_only=) \033[0m"
	$(MAKE) -C $(@:_only=)
	@mkdir -p $(DESTDIR)
	@echo "\033[1;30;42m $(@:_only=) \033[0m \033[1;30;44m Installing \033[0m"
	@if $(MAKE) -C $(@:_only=) install; then \
		touch $(DESTDIR)/.installed_$(@:_only=); \
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
	rm -f $(DESTDIR)/.installed_$(@:_clean=)
