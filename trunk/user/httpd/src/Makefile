ifndef ROOTDIR
ROOTDIR=../..
endif

include $(BOARD_CONFIG)
include $(CFLAGS_CONFIG)

CFLAGS += -I.

LDFLAGS += -L. -lm
LDFLAGS += -lshared
LDFLAGS += -liw
ifeq ($(STORAGE_ENABLED),y)
LDFLAGS += -ldisk
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_HTTPS),y)
LDFLAGS += -lssl -lcrypto
endif

EXEC = httpd
OBJS = httpd.o ej.o cgi.o web_ex.o common.o nvram_x.o ralink.o crc32.o base64.o aspbw.o initial_web_hook.o variables.o
OBJS += tdate_parse.o upload.o
ifeq ($(CONFIG_FIRMWARE_INCLUDE_HTTPS),y)
OBJS += https.o
# musl provides fopencookie() natively; only compile the compat shim for
# libcs that lack it (e.g. uClibc).
ifeq ($(findstring musl,$(CROSS_COMPILE)),)
OBJS += fopencookie_compat.o
endif
endif
ifeq ($(STORAGE_ENABLED),y)
OBJS += aidisk.o
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
# 6.x: MT7530 DSA replaces the vendor GSW driver; switch_mtk_esw.c is
# sysfs-based and needs no raeth kernel headers.
ifdef CONFIG_NET_DSA_MT7530
OBJS += switch_mtk_esw.o
endif
endif
endif
endif
OBJS += dbapi.o
all: $(OBJS) Makefile
	$(CC) -o $(EXEC) $(OBJS) $(LDFLAGS)
	$(STRIP) $(EXEC)

c.o:
	$(CC) -c $*.c $(CFLAGS)

clean:
	rm -f *.o *~ httpd

romfs:
	$(ROMFSINST) /usr/sbin/httpd
ifeq ($(CONFIG_FIRMWARE_INCLUDE_HTTPS),y)
	$(ROMFSINST) /usr/bin/https-cert.sh
endif
