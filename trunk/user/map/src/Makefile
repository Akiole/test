EXEC = map_controller map_agent

all: $(EXEC)

map_controller: map_controller.o
	$(CC) -o $@ $^ $(LDFLAGS) $(CFLAGS)

map_agent: map_agent.o
	$(CC) -o $@ $^ $(LDFLAGS) $(CFLAGS)

%.o: %.c map_common.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf *.o $(EXEC) *~
