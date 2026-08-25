LUA      = ../../lua51/lua-5.1.5/src
STATIC   = false
CFLAGS   += -O2 -Wall
CPPFLAGS += -O2 -fno-exceptions -fno-rtti -I$(LUA) -L$(LUA) -D_LARGEFILE64_SOURCE
SRC      = main.cpp soap.cpp mem.cpp mcast.cpp luaxlib.cpp luaxcore.cpp luajson.cpp luajson_parser.cpp
# -fPIC: lua objects built here are later linked into liblua.so by user/lua51;
# without PIC the shared link fails with R_MIPS_26 relocation errors.
LUAMYCFLAGS = -DLUA_USE_LINUX -fPIC

ifeq ($(STATIC),true)
CFLAGS+=-static
LUAMYCFLAGS+=-static
endif

embedded:
	make -C $(LUA) a MYCFLAGS='$(LUAMYCFLAGS)' CC='$(CC)' AR='$(AR) rcu' RANLIB='$(RANLIB)'
	$(CC) $(CFLAGS) -c -o md5.o md5c.c
	$(CXX) $(CPPFLAGS) $(LDFLAGS) -DWITH_URANDOM -o xupnpd $(SRC) md5.o -llua -lm -ldl

clean:
	make -C $(LUA) clean
	rm -f $(LUA)/liblua.a
	rm -f md5.o
	rm -f xupnpd
