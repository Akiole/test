CFLAGS  += -I. -Wmissing-declarations
#CFLAGS += -DDEBUG_PACKET -DDEBUG -g3
LDFLAGS += -Llibubox -lubox

TARGET = uqmi
SOURCES = main.c dev.c commands.c qmi-message.c

service_sources = $(foreach service,ctl dms nas pds wds wms,qmi-message-$(service).c)
service_headers = $(service_sources:.c=.h)

SOURCES += $(service_sources)
OBJS=$(SOURCES:.c=.o)

all: lubox gen-errors gen-headers $(TARGET)

gen-errors: qmi-errors.c

qmi-errors.c: qmi-errors.h data/gen-error-list.pl
	data/gen-error-list.pl $< > $@

gen-headers: $(service_headers)

qmi-message-%.h: data/qmi-service-%.json data/gen-header.pl data/gen-common.pm
	data/gen-header.pl $*_ $< > $@

qmi-message-%.c: data/qmi-service-%.json data/gen-code.pl data/gen-common.pm
	data/gen-code.pl $*_ $< > $@

qmi-message-%.o: CFLAGS += -Wno-unused

$(OBJS): $(service_headers) qmi-errors.c

lubox:
	$(MAKE) -C libubox

$(TARGET): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

romfs:
	$(ROMFSINST) /bin/uqmi

clean:
	rm -f $(TARGET) $(OBJS) qmi-errors.c $(service_sources) $(service_headers)
	$(MAKE) -C libubox clean
