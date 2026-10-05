include $(BOARD_CONFIG)
include $(CFLAGS_CONFIG)

CFLAGS += -s -I.
CFLAGS += -I$(ROOTDIR)/$(LINUXDIR)/include/ralink
# uClibc + GCC 13: legacy code triggers format-overflow/restrict warnings;
# they are harmless for this codebase, silence them.
CFLAGS += -Wno-format-overflow -Wno-restrict

# Disable/Enable ugly httpd_check
#CFLAGS += -DHTTPD_CHECK

LDFLAGS += -L. -lm
LDFLAGS += -liw -lshared
ifeq ($(STORAGE_ENABLED),y)
LDFLAGS += -ldisk
endif

EXEC = rc

OBJS  = rc.o init.o auth.o services.o watchdog.o firewall_ex.o common_ex.o
OBJS += net.o net_lan.o net_wan.o net_wifi.o net_ppp.o services_ex.o rstats.o
OBJS += ralink.o gpio_pins.o detect_link.o detect_internet.o detect_wan.o
OBJS += vpn_server.o vpn_client.o
OBJS += gpio_btn.o btn_action.o
ifeq ($(CONFIG_FIRMWARE_INCLUDE_OPENVPN),y)
OBJS += vpn_openvpn.o
endif
ifeq ($(STORAGE_ENABLED),y)
OBJS += hotplug_stor.o
OBJS += services_stor.o
endif
# Userspace USB services are gated on USE_USB_SUPPORT (set by cflags.mk when
# BOARD_NUM_USB_PORTS != 0), not on the kernel CONFIG_USB_SUPPORT: the latter
# is always y on 6.x mt7621 (USB host stack) yet the USB service objects
# include libdisk headers (usb_info.h/dev_info.h) that only exist when
# storage support (libdisk) is built.
ifdef USE_USB_SUPPORT
OBJS += hotplug_usb.o usb_modem.o services_usb.o
endif
ifdef CONFIG_RTL8367
OBJS += switch_rtl8367.o
CFLAGS += -I$(ROOTDIR)/$(LINUXDIR)/drivers/net/ethernet/raeth/rtl8367c
else
ifdef CONFIG_RAETH
OBJS += switch_mtk_esw.o
CFLAGS += -I$(ROOTDIR)/$(LINUXDIR)/drivers/net/ethernet/raeth
else
ifdef CONFIG_RAETH_ESW
OBJS += switch_mtk_esw.o
CFLAGS += -I$(ROOTDIR)/$(LINUXDIR)/drivers/net/ethernet/raeth
else
# 6.x: MT7530 DSA replaces the vendor GSW driver; switch_mtk_esw.c provides
# the DSA/phy helpers (dsa_port_netdev, phy_*) used by net_lan.c and is
# sysfs-based, needing no raeth kernel headers.
ifdef CONFIG_NET_DSA_MT7530
OBJS += switch_mtk_esw.o
endif
endif
endif
endif
ifdef CONFIG_RT3352_INIC_MII
OBJS += inicd.o
endif
ifdef CONFIG_IPV6
OBJS += net6.o net_lan6.o net_wan6.o
endif
ifdef CONFIG_SMP
OBJS += smp.o
endif

all: $(OBJS) Makefile
	$(CC) -o $(EXEC) $(OBJS) $(LDFLAGS)
	$(STRIP) $(EXEC)

c.o:
	$(CC) -c $*.c $(CFLAGS)

clean:
	rm -f *.o rc
