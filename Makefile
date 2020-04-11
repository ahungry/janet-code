CC=gcc
CFLAGS=-c -Wall -std=gnu99
LFLAGS=-lm -ldl

all: janet_modules deps build

WINCC=x86_64-w64-mingw32-gcc

standalone.bin: standalone.c
	$(CC) -g -std=c99 -Wall -fPIC -I./amalg -I/usr/include/curl \
	amalg/janet.c $< -o $@ -lm -ldl -lrt -lpthread -lcurl

standalone.exe: standalone.c
	$(WINCC) -g -std=c99 -fPIC -static -I./amalg -I/usr/x86_64-w64-mingw32/include/curl \
	amalg/janet.c $< -o $@ -lm -lcurl -DCURL_STATIC_LIB -lws2_32 -lwinmm

rebuild:
	-rm -f build/main
	-rm -f build/main.o
	make build/main

# Try out an amalgamated build in one step (we probably don't want to build o file each time)
build/main: build/janet.o build/main.o
	$(CC) build/main.o build/janet.o -o build/main $(LFLAGS)

build/main.o:
	$(CC) $(CFLAGS) main.c -o build/main.o

build/janet.o:
	$(CC) $(CFLAGS) amalg/janet.c -o build/janet.o

# Build our own native modules based on project.janet declaration
build: *.c
	jpm build

docker-build:
	docker build -t janet .

docker-run:
	docker run --rm -it --net=host --name=janet janet:latest

docker-build-raycast:
	docker build -f Dockerfile_raycast -t janet-raycast .

docker-run-raycast:
	docker run --rm -it --net=host --name=janet-raycast janet-raycast:latest

clean:
	-rm -fr deps
	-rm -fr janet_modules

# deps:
# 	jpm deps

# will pull circlet and deps from git and install it into the janet_modules tree.
janet_modules:
	-mkdir -p janet_modules
	jpm --modpath=./janet_modules install https://github.com/janet-lang/sqlite3.git
	jpm --modpath=./janet_modules install https://github.com/janet-lang/circlet.git
	jpm --modpath=./janet_modules install https://github.com/janet-lang/json.git
	# But, for some reason, we need the .so to bubble up to the top for usage.

deps:
	sh find-deps.sh

run:
	#janet -m ./deps myserver.janet
	janet myserver.janet

cairo.bin: cairo.c
	gcc -Wall $(shell pkg-config --libs cairo) -I/usr/include/cairo -o $@ $<
