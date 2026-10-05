# =============================================================================
# User Applications Top-Level Makefile
# =============================================================================

.PHONY: all romfs clean

ifndef ROOTDIR
# Resolve to absolute path: a relative '..' would break when sub-makes
# (make -C <pkg>) inherit it, since their CWD is one level deeper.
ROOTDIR := $(abspath ..)
endif
export ROOTDIR
ifndef ROMFSDIR
ROMFSDIR = $(ROOTDIR)/romfs
endif

UCLINUX_BUILD_USER = 1

-include $(LINUX_CONFIG)
include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)
include $(ROOTDIR)/host-tools.mk

CFLAGS   += -ffunction-sections -fdata-sections
CPPFLAGS += -ffunction-sections -fdata-sections
LDFLAGS  += -Wl,--gc-sections

INSTALLDIR   = $(ROMFSDIR)
BOARD_CONFIG = $(ROOTDIR)/user/boards.mk
CFLAGS_CONFIG = $(ROOTDIR)/user/cflags.mk

# -----------------------------------------------------------------------------
# Feature aggregation
# -----------------------------------------------------------------------------
DROPBEAR_ENABLED    = n
OPENSSH_ENABLED     = n
SAMBA_ENABLED       = n
STORAGE_ENABLED     = n
FS_EXT_ENABLED      = n
FS_FAT_ENABLED      = n
FS_NTFS_ENABLED     = n
FRP_ENABLED          = n
SHADOWSOCKS_ENABLED  = n
SOFTETHERVPN_ENABLED = n
TROJAN_ENABLED       = n

# SSH: OpenSSH priority over DropBear; SFTP needs OpenSSH sftp-server
ifneq ($(CONFIG_FIRMWARE_INCLUDE_OPENSSH),y)
  ifeq ($(CONFIG_FIRMWARE_INCLUDE_DROPBEAR),y)
    DROPBEAR_ENABLED = y
    ifeq ($(CONFIG_FIRMWARE_INCLUDE_SFTP),y)
      OPENSSH_ENABLED = y
    endif
  endif
else
  OPENSSH_ENABLED = y
endif

ifneq ($(filter y,$(CONFIG_BLK_DEV_SD) $(CONFIG_MMC_BLOCK)),)
STORAGE_ENABLED = y
endif

ifeq ($(STORAGE_ENABLED),y)
  ifneq ($(filter y,$(CONFIG_FIRMWARE_ENABLE_EXT2) $(CONFIG_FIRMWARE_ENABLE_EXT3) $(CONFIG_FIRMWARE_ENABLE_EXT4)),)
    FS_EXT_ENABLED = y
  endif
  ifneq ($(filter y,$(CONFIG_FIRMWARE_ENABLE_FAT) $(CONFIG_FIRMWARE_ENABLE_EXFAT)),)
    FS_FAT_ENABLED = y
  endif
  ifeq ($(CONFIG_FIRMWARE_INCLUDE_NTFS_3G),y)
    FS_NTFS_ENABLED = y
  endif
  ifeq ($(CONFIG_FIRMWARE_INCLUDE_SMBD),y)
    SAMBA_ENABLED = y
  endif
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_WINS),y)
SAMBA_ENABLED = y
endif

ifneq ($(filter y,\
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CMD) \
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CLIENT) \
	$(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_SERVER)),)
SOFTETHERVPN_ENABLED = y
endif

ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_SSSERVER) $(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)),)
SHADOWSOCKS_ENABLED = y
endif

ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_FRPC) $(CONFIG_FIRMWARE_INCLUDE_FRPS)),)
FRP_ENABLED = y
endif

ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_WING) $(CONFIG_FIRMWARE_INCLUDE_TROJAN)),)
TROJAN_ENABLED = y
endif

# -----------------------------------------------------------------------------
# Build dir collection
# -----------------------------------------------------------------------------
dir_y =
dir_n =
dir_  =

ALL_USER_DIRS := $(sort $(patsubst %/,%,$(wildcard */)))

# Tier 1: base components
dir_y += shared
dir_y += nvram
dir_y += utils
dir_y += mtd_write

# Tier 2: core system tools
dir_y += busybox
dir_y += iptables
dir_y += ebtables
dir_y += iproute2
dir_y += wireless-tools
ifeq ($(CONFIG_FIRMWARE_INCLUDE_COREMARK),y)
dir_y += coremark
endif
dir_y += ralinkiappd

dir_$(STORAGE_ENABLED) += libdisk

# Tier 3: network base services
dir_y += dnsmasq
dir_y += igmpproxy
ifeq ($(CONFIG_FIRMWARE_INCLUDE_INADYN),y)
dir_y += inadyn
endif
dir_y += miniupnpd

# UDPXY and MSD_LITE are mutually exclusive
ifeq ($(CONFIG_FIRMWARE_INCLUDE_MSD_LITE),y)
dir_y += msd_lite
else
dir_y += udpxy
endif

# Tier 4: web management & system services
dir_y += networkmap
dir_y += httpd
dir_y += www
dir_y += rc
dir_y += skipdbv2

# Dial-up & authentication
dir_y += pppd
dir_y += pppoe
dir_y += pppoe-relay
dir_y += poptop
dir_y += xl2tpd
dir_$(CONFIG_FIRMWARE_INCLUDE_RPL2TP) += rp-l2tp
dir_$(CONFIG_FIRMWARE_INCLUDE_WPA_SUPPLICANT) += wpa_supplicant
dir_y += 802.1x
dir_y += lanauth
dir_y += lldt
dir_y += scripts

ifneq ($(CONFIG_WITHOUT_KERNEL),y)
dir_$(CONFIG_FIRMWARE_INCLUDE_IPSET) += ipset
endif

# Tier 5: SSH / file sharing / VPN
dir_$(OPENSSH_ENABLED)       += openssh
dir_$(DROPBEAR_ENABLED)      += dropbear
dir_$(SAMBA_ENABLED)          += samba36
dir_$(SAMBA_ENABLED)          += wsdd2
dir_$(FRP_ENABLED)            += frp
dir_$(SOFTETHERVPN_ENABLED)   += softethervpn

# Tier 6: optional packages (alphabetical)
dir_$(CONFIG_FIRMWARE_INCLUDE_3PROXY)       += 3proxy
dir_$(CONFIG_FIRMWARE_INCLUDE_ADBYBY)       += adbyby
dir_$(CONFIG_FIRMWARE_INCLUDE_ADGUARDHOME)  += adguardhome
dir_$(CONFIG_FIRMWARE_INCLUDE_ALIDDNS)      += aliddns
dir_$(CONFIG_FIRMWARE_INCLUDE_ALDRIVER)     += aliyundrive-webdav
dir_$(CONFIG_FIRMWARE_INCLUDE_ANTFS)        += antfs
dir_$(CONFIG_FIRMWARE_INCLUDE_DDNSTO)       += ddnsto
dir_$(CONFIG_FIRMWARE_INCLUDE_DNSFORWARDER) += dns-forwarder
dir_$(CONFIG_FIRMWARE_INCLUDE_DOGCOM)       += dogcom
dir_$(CONFIG_FIRMWARE_INCLUDE_GDUT_DRCOM)   += gdut-drcom
dir_$(CONFIG_FIRMWARE_INCLUDE_HTOP)         += htop
dir_$(CONFIG_FIRMWARE_INCLUDE_IPERF3)       += iperf3
dir_$(CONFIG_FIRMWARE_INCLUDE_LRZSZ)        += lrzsz
dir_$(CONFIG_FIRMWARE_INCLUDE_MTR)          += mtr
dir_$(CONFIG_FIRMWARE_INCLUDE_MENTOHUST)    += mentohust
dir_$(CONFIG_FIRMWARE_INCLUDE_MICROSOCKS)   += microsocks
dir_$(CONFIG_FIRMWARE_INCLUDE_MINIEAP)      += minieap
dir_$(CONFIG_FIRMWARE_INCLUDE_NANO)         += nano
dir_$(CONFIG_FIRMWARE_INCLUDE_NJIT_CLIENT)  += njit-client
dir_$(CONFIG_FIRMWARE_INCLUDE_OPENVPN)      += openvpn
dir_$(CONFIG_FIRMWARE_INCLUDE_REDSOCKS)     += redsocks
dir_$(CONFIG_FIRMWARE_INCLUDE_SCUTCLIENT)   += scutclient
dir_$(CONFIG_FIRMWARE_INCLUDE_SMARTDNS)     += smartdns
dir_$(CONFIG_FIRMWARE_INCLUDE_SOCAT)        += socat
dir_$(CONFIG_FIRMWARE_INCLUDE_SQM)          += sqm-qos
dir_$(CONFIG_FIRMWARE_INCLUDE_SRELAY)       += srelay
dir_$(CONFIG_FIRMWARE_INCLUDE_SSWAN)        += strongswan
dir_$(CONFIG_FIRMWARE_INCLUDE_TCPDUMP)      += tcpdump
dir_$(CONFIG_FIRMWARE_INCLUDE_TTYD)         += ttyd
dir_$(CONFIG_FIRMWARE_INCLUDE_VLMCSD)       += vlmcsd
dir_$(CONFIG_FIRMWARE_INCLUDE_xTUN)         += xTun
# lua51 is required by xupnpd and shadowsocks; must build before them
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_XUPNPD) $(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS)),)
dir_y += lua51
endif
dir_$(CONFIG_FIRMWARE_INCLUDE_XUPNPD)        += xupnpd
dir_$(CONFIG_FIRMWARE_INCLUDE_ZEROTIER)      += zerotier
dir_$(CONFIG_FIRMWARE_INCLUDE_NATMAP)        += natmap
dir_$(CONFIG_FIRMWARE_INCLUDE_N2N)           += n2n
dir_$(CONFIG_FIRMWARE_INCLUDE_RTP2HTTPD)     += rtp2httpd
dir_$(CONFIG_FIRMWARE_INCLUDE_FAKEHTTP)      += fakehttp
dir_$(CONFIG_FIRMWARE_INCLUDE_FAKESIP)       += fakesip
dir_$(CONFIG_FIRMWARE_INCLUDE_WEBDAV)        += webdav
dir_$(CONFIG_FIRMWARE_INCLUDE_TMUX)          += tmux
dir_$(CONFIG_FIRMWARE_INCLUDE_NEOFETCH)      += neofetch
dir_$(CONFIG_FIRMWARE_INCLUDE_JQ)            += jq

# Tier 7: proxy ecosystem
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS),y)
dir_y += shadowsocks
dir_$(CONFIG_FIRMWARE_INCLUDE_NAIVEPROXY) += naiveproxy
dir_$(CONFIG_FIRMWARE_INCLUDE_TROJAN)     += trojan
dir_$(CONFIG_FIRMWARE_INCLUDE_V2RAY)      += v2ray
dir_$(CONFIG_FIRMWARE_INCLUDE_XRAY)       += xray
dir_$(CONFIG_FIRMWARE_INCLUDE_SSOBFS)     += simple-obfs
dir_y += chinadns-ng
dir_y += chnroute
dir_y += dns2tcp
dir_y += dnsproxy
dir_y += ipt2socks
dir_y += resolveip
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SINGBOX),y)
dir_y += sing-box
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_MIHOMO),y)
dir_y += mihomo
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_WING),y)
dir_y += wing
dir_y += ipt2socks
endif

ifeq ($(CONFIG_FIRMWARE_INCLUDE_WIREGUARD),y)
dir_y += wireguard
dir_y += wireguard-tools
dir_y += wg-quick
endif

# Tier 8: USB & storage extensions
ifdef CONFIG_USB_SUPPORT
dir_y += comgt
dir_y += p910nd
dir_y += uqmi
dir_y += usb-modeswitch
dir_$(CONFIG_FIRMWARE_INCLUDE_DUMP1090) += dump1090
dir_$(CONFIG_FIRMWARE_INCLUDE_LPRD)     += LPRng
dir_$(CONFIG_FIRMWARE_INCLUDE_U2EC)     += u2ec
endif

ifdef CONFIG_BLK_DEV_SD
dir_$(CONFIG_FIRMWARE_INCLUDE_HDPARM)   += hdparm
endif

ifeq ($(STORAGE_ENABLED),y)
dir_y += util-linux
dir_$(CONFIG_FIRMWARE_INCLUDE_NFSD) += nfs-utils
ifneq ($(filter y,$(CONFIG_FIRMWARE_INCLUDE_NFSD) $(CONFIG_FIRMWARE_INCLUDE_NFSC)),)
dir_y += rpcbind
endif
dir_y += optware
dir_$(FS_FAT_ENABLED)                  += dosfstools
dir_$(FS_EXT_ENABLED)                  += e2fsprogs
dir_$(FS_NTFS_ENABLED)                 += ntfs-3g
dir_$(CONFIG_FIRMWARE_INCLUDE_ARIA)         += aria2
dir_$(CONFIG_FIRMWARE_INCLUDE_FIREFLY)      += firefly
dir_$(CONFIG_FIRMWARE_INCLUDE_MINIDLNA)     += minidlna
dir_$(CONFIG_FIRMWARE_INCLUDE_PARTED)       += parted
dir_$(CONFIG_FIRMWARE_INCLUDE_FTPD)         += vsftpd
dir_$(CONFIG_FIRMWARE_INCLUDE_TRANSMISSION) += transmission
endif

ifdef CONFIG_MTD_UBI
ifneq ($(STORAGE_ENABLED),y)
dir_y += optware
dir_y += util-linux
endif
dir_y += mtd-utils
endif

# Dedup (order-preserving; do NOT use $(sort) — alphabetical breaks util-linux -> nfs-utils dep)
define _uniq
$(if $1,$(firstword $1) $(call _uniq,$(filter-out $(firstword $1),$1)))
endef
dir_y := $(call _uniq,$(dir_y))

BUILD_TARGETS := $(patsubst %,%_only,$(dir_y))

# =============================================================================
# Targets
# =============================================================================
all: $(BUILD_TARGETS)
romfs: $(patsubst %,%_romfs,$(dir_y))
clean: $(patsubst %,%_clean,$(ALL_USER_DIRS))

# =============================================================================
# Order-only deps (parallel safety)
# =============================================================================
ifneq ($(filter shared_only,$(BUILD_TARGETS)),)
$(filter-out shared_only nvram_only utils_only mtd_write_only,$(BUILD_TARGETS)): | shared_only
endif
ifneq ($(filter nvram_only,$(BUILD_TARGETS)),)
$(filter-out shared_only nvram_only utils_only mtd_write_only,$(BUILD_TARGETS)): | nvram_only
endif
ifneq ($(filter utils_only,$(BUILD_TARGETS)),)
$(filter-out shared_only nvram_only utils_only mtd_write_only,$(BUILD_TARGETS)): | utils_only
endif

# nvram needs shared headers and libshared.so
ifneq ($(filter nvram_only,$(BUILD_TARGETS)),)
nvram_only: | shared_only
endif

# httpd needs shared + nvram + wireless-tools + libdisk
ifneq ($(filter httpd_only,$(BUILD_TARGETS)),)
httpd_only: | $(filter shared_only,$(BUILD_TARGETS)) $(filter nvram_only,$(BUILD_TARGETS)) \
              $(filter wireless-tools_only,$(BUILD_TARGETS)) $(filter libdisk_only,$(BUILD_TARGETS))
endif

# rc needs httpd
ifneq ($(filter rc_only,$(BUILD_TARGETS)),)
rc_only: | $(filter httpd_only,$(BUILD_TARGETS))
endif

# nfs-utils needs util-linux (libuuid)
ifneq ($(filter nfs-utils_only,$(BUILD_TARGETS)),)
nfs-utils_only: | $(filter util-linux_only,$(BUILD_TARGETS))
endif

# parted needs util-linux (libuuid)
ifneq ($(filter parted_only,$(BUILD_TARGETS)),)
parted_only: | $(filter util-linux_only,$(BUILD_TARGETS))
endif

# miniupnpd needs iptables (libiptc/libip4tc)
ifneq ($(filter miniupnpd_only,$(BUILD_TARGETS)),)
miniupnpd_only: | $(filter iptables_only,$(BUILD_TARGETS))
endif

# =============================================================================
# Pattern rules
# =============================================================================
%_only:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m $(@:_only=) \033[0m"
	@$(MAKE) -C $(@:_only=) || { \
		echo ""; \
		echo "\033[1;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"; \
		echo "\033[1;31m  ❌ Package build failed: $(@:_only=)\033[0m"; \
		echo "\033[1;31m  📂 Scroll up for the actual configure/compile error\033[0m"; \
		echo "\033[1;31m  🔧 Rebuild alone for details: make -C user/$(@:_only=) V=99\033[0m"; \
		echo "\033[1;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"; \
		exit 1; \
	}

%_romfs:
	@echo "\033[1;30;42m ROMFS \033[0m \033[1;30;44m $(@:_romfs=) \033[0m"
	@$(MAKE) -C $(@:_romfs=) romfs || { \
		echo "\033[1;31m===> ❌ Romfs failed: $(@:_romfs=). See above for details.\033[0m"; \
		exit 1; \
	}

%_clean:
	@echo "\033[1;30;42m CLEAN \033[0m \033[1;30;44m $(@:_clean=) \033[0m"
	-@$(MAKE) -C $(@:_clean=) clean
