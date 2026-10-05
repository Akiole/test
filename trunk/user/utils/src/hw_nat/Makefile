EXEC = hw_nat 

HWNAT_OBJS = hw_nat.o hwnat_api.o util.o

CONF_H := $(ROOTDIR)/$(CONFIG_LINUXDIR)/include/generated/autoconf.h

CFLAGS += -I$(ROOTDIR)/$(CONFIG_LINUXDIR)/include
CFLAGS += -I$(ROOTDIR)/$(CONFIG_LINUXDIR)/net/nat/hw_nat/
CFLAGS += -I$(ROOTDIR)/$(CONFIG_LINUXDIR)/arch/mips/include
CFLAGS += -Wall
# NIPQUAD/NIPHALF macros use pointer type-punning (kernel-style); the
# kernel foe table uses a zero-length array for the tuple pool.  Both
# are intentional and fire on every inclusion of hwnat_api.h.
CFLAGS += -Wno-strict-aliasing -Wno-zero-length-bounds

all: $(EXEC)

hw_nat: $(HWNAT_OBJS) $(CONF_H)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(HWNAT_OBJS) 

clean:
	rm -f $(EXEC) *.o
