# Path from your 'brew --prefix libpq' command
PG_BASE = /opt/homebrew/opt/libpq
CC = gcc

# Adding the exact include and lib paths
CFLAGS = -I$(PG_BASE)/include
LIBS = -L$(PG_BASE)/lib -lpq

all:
	$(CC) src/main.c -o transit_system $(CFLAGS) $(LIBS)

clean:
	rm -f transit_system