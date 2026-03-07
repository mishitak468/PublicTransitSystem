MYSQL_PATH = /usr/local/mysql
CC = gcc
CFLAGS = -I$(MYSQL_PATH)/include
LIBS = -L$(MYSQL_PATH)/lib -lmysqlclient -Wl,-rpath,$(MYSQL_PATH)/lib

all:
	$(CC) src/main.c -o transit_system $(CFLAGS) $(LIBS)

clean:
	rm -f transit_system