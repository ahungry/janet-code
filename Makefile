CC=gcc
CFLAGS=-c -Wall -std=gnu99
LFLAGS=-lm -ldl

all: janet_modules deps

rebuild:
	-rm -f build/main
	-rm -f build/main.o
	make build/main

# Try out an amalgamated build in one step (we probably don't want to build o file each time)
build/main: build/janet.o build/main.o
	$(CC) $(LFLAGS) build/main.o build/janet.o -o build/main

build/main.o:
	$(CC) $(CFLAGS) main.c -o build/main.o

build/janet.o:
	$(CC) $(CFLAGS) amalg/janet.c -o build/janet.o

# Build our own native modules based on project.janet declaration
build:
	jpm build

docker-build:
	docker build -t janet .

docker-run:
	docker run --rm -it --net=host --name=janet janet:latest

clean:
	-rm -fr deps
	-rm -fr janet_modules

# deps:
# 	jpm deps

# will pull circlet and deps from git and install it into the janet_modules tree.
janet_modules:
	-mkdir -p janet_modules
	jpm --modpath=./janet_modules install https://github.com/ahungry/sqlite3.git
	jpm --modpath=./janet_modules install https://github.com/ahungry/circlet.git
	jpm --modpath=./janet_modules install https://github.com/ahungry/json.git
	# But, for some reason, we need the .so to bubble up to the top for usage.

deps:
	sh find-deps.sh

run:
	#janet -m ./deps myserver.janet
	janet myserver.janet
