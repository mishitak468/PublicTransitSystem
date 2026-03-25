PG_BASE = /opt/homebrew/opt/libpq
CC = gcc

CFLAGS = -I$(PG_BASE)/include
LIBS = -L$(PG_BASE)/lib -lpq

all:
	$(CC) src/main.c -o transit_system $(CFLAGS) $(LIBS)

clean:
	rm -f transit_system