# -*- mode: makefile-gmake-mode -*-
CC=gcc
WINCC=x86_64-w64-mingw32-gcc
WIN32CC=i686-w64-mingw32-gcc
CFLAGS=-c -Wall -std=gnu99
LFLAGS=-lm -ldl

all: janet_modules deps build

build-curl:
	./build-curl.sh

app-static.exe: app.c
	$(WINCC) -g -std=c99 -Wall -Wl,-Bstatic -I./amalg -I/usr/include/iup \
	-I/usr/x86_64-w64-mingw32/include/curl \
	amalg/janet.c $< -o $@ -static -lm -L/usr/x86_64-w64-mingw32/lib \
	-pthread -L. \
	libcurl.dll.a -DCURL_STATICLIB -lws2_32 -lwinmm \
	-l:libiup_scintilla.a -l:libfreetype6.a \
	-l:libftgl.a -l:libiupcd.a -l:libiupcontrols.a -l:libiupgl.a -l:libiupglcontrols.a \
	-l:libiupim.a -l:libiup_mglplot.a -l:libiupole.a -l:libiup_plot.a \
	-l:libiuptuio.a -l:libz.a -l:libiup.a -l:libiupimglib.a \
	-lmingw32 -lopengl32 -lpangowin32-1.0 -lgdi32 -lws2_32 -luuid -lcomctl32 -lole32  \
	-lcomdlg32

app.bin: app.c
	$(CC) -g -std=c99 -Wall -fPIC -I./amalg \
	-I/usr/include/iup \
	-I/usr/include/curl \
	amalg/janet.c $< -o $@ \
	-pthread -lm -ldl -lrt -lpthread \
	-lz -ldl -lcurl -liup -liupimglib

# https://sourceforge.net/projects/iup/files/
app-motif.bin: app.c
	$(CC) -g -std=c99 -Wall -fPIC -I./amalg \
	-I/usr/include/iup \
	-I/usr/include/curl \
	amalg/janet.c $< -o $@ \
	-pthread -lrt \
	-lcurl -lXm -lXmu -lXt -lX11 -liup -liupimglib -lm -lz -ldl

# Eww https://mail.gnome.org/archives/gtk-list/2018-January/msg00006.html
app-static.bin: app.c
	$(CC) -g -std=c99 -Wall -fPIC -static -I./amalg \
	-I/usr/include/iup \
	-I/usr/include/curl \
	`pkg-config --cflags gtk+-3.0` \
	amalg/janet.c $< -o $@ \
	-DCURL_STATICLIB \
	-Wl,-Bstatic \
	-L/usr/lib \
	-pthread -lrt \
	iup-linux64/libiup.a  iup-linux64/libiupcd.a  iup-linux64/libiupcontrols.a  iup-linux64/libiupgl.a  iup-linux64/libiupglcontrols.a  iup-linux64/libiupim.a  iup-linux64/libiupimglib.a  iup-linux64/libiup_mglplot.a  iup-linux64/libiup_plot.a  iup-linux64/libiup_scintilla.a  iup-linux64/libiuptuio.a  iup-linux64/libiupweb.a \
	libcurl-nix-x86_64.a \
	openssl/libssl.a \
	openssl/libcrypto.a \
	libcares.a \
	-Wl,-Bdynamic \
	`pkg-config --libs gtk+-3.0` \
	-lX11 -lm -lz -ldl -static-libgcc

patch-elf:
	readelf -l app-static.bin | grep interpre
	patchelf --set-interpreter /lib/ld-linux-x86-64.so.2 ./app-static.bin
	readelf -l app-static.bin | grep interpre

standalone.bin: standalone.c
	$(CC) -g -std=c99 -Wall -fPIC -I./amalg -I/usr/include/curl \
	amalg/janet.c $< -o $@ -lm -ldl -lrt -lpthread -lcurl

standalone.exe: standalone.c
	$(WINCC) -g -std=c99 -fPIC -static -I./amalg -I/usr/x86_64-w64-mingw32/include/curl \
	amalg/janet.c $< -o $@ -lm libcurl.dll.a -DCURL_STATICLIB -lws2_32 -lwinmm

standalone32.exe: standalone.c
	$(WIN32CC) -g -std=c99 -fPIC -static -I./amalg -I/usr/i686-w64-mingw32/include/curl \
	amalg/janet.c $< -o $@ -lm libcurl32.dll.a -DCURL_STATICLIB -lws2_32 -lwinmm

#x86_64-w64-mingw32-gcc -g -std=c99 -I./amalg -I/usr/x86_64-w64-mingw32/include/curl amalg/janet.c standalone.c -o standalone.exe -DCURL_STATICLIB -static libcurl.dll.a -lwinmm -lm -lz -lws2_32

iup.bin: iup.c
	$(CC) -g -std=c99 -Wall -fPIC -I./amalg -I/usr/include/iup \
	amalg/janet.c $< -o $@ -lm -ldl -lrt -lpthread -liup -liupimglib

iup.exe: iup.c
	$(WINCC) -g -std=c99 -Wall -fPIC -I./amalg -I/usr/include/iup \
	amalg/janet.c $< -o $@ -lm -pthread libiup.a libiupimglib.a

iup-static.exe: iup.c
	$(WINCC) -g -std=c99 -Wall -Wl,-Bstatic -I./amalg -I/usr/include/iup \
	amalg/janet.c $< -o $@ -static -lm -L/usr/x86_64-w64-mingw32/lib \
	-pthread -L. \
	-l:libiup_scintilla.a -l:libfreetype6.a \
	-l:libftgl.a -l:libiupcd.a -l:libiupcontrols.a -l:libiupgl.a -l:libiupglcontrols.a \
	-l:libiupim.a -l:libiup_mglplot.a -l:libiupole.a -l:libiup_plot.a \
	-l:libiuptuio.a -l:libz.a -l:libiup.a -l:libiupimglib.a \
	-lmingw32 -lopengl32 -lpangowin32-1.0 -lgdi32 -lws2_32 -luuid -lcomctl32 -lole32  \
	-lcomdlg32

dll:
	mkdir dll
	wget https://curl.haxx.se/windows/dl-7.69.1_1/curl-7.69.1_1-win64-mingw.zip -P dll/
	wget https://curl.haxx.se/windows/dl-7.69.1_1/openssl-1.1.1f_1-win64-mingw.zip -P dll/
	wget https://curl.haxx.se/windows/dl-7.69.1_1/brotli-1.0.7_1-win64-mingw.zip -P dll/
	wget https://curl.haxx.se/windows/dl-7.69.1_1/nghttp2-1.40.0_1-win64-mingw.zip -P dll/

unzip-dlls:
	cd dll && find . -name '*.zip' -exec unzip {} \;

window-deps: dll unzip-dlls
	find dll -name libcurl-x64.dll -exec cp {} ./ \;
	find dll -name libcurl.a -exec cp {} ./ \;
	find dll -name libcrypto-1_1-x64.dll -exec cp {} ./ \;
	find dll -name libcurl.dll.a -exec cp {} ./ \;
	find dll -name libssl-1_1-x64.dll -exec cp {} ./ \;

gui.bin: gui.c
	gcc `pkg-config --cflags gtk+-3.0` -o $@ $< `pkg-config --libs gtk+-3.0`

# $(WINCC) `pkg-config --cflags gtk+-3.0` -o $@ $< `pkg-config --libs gtk+-3.0`

gui.exe: gui.c
	$(WINCC) -I/usr/x86_64-w64-mingw32/include/gtk-3.0 -I/usr/x86_64-w64-mingw32/include/pango-1.0 -I/usr/x86_64-w64-mingw32/include/glib-2.0 -I/usr/x86_64-w64-mingw32/lib/glib-2.0/include -I/usr/x86_64-w64-mingw32/lib/libffi-3.2.1/include -I/usr/x86_64-w64-mingw32/include/harfbuzz -I/usr/x86_64-w64-mingw32/include/fribidi -I/usr/x86_64-w64-mingw32/include/freetype2 -I/usr/x86_64-w64-mingw32/include/libpng16 -I/usr/x86_64-w64-mingw32/include/cairo -I/usr/x86_64-w64-mingw32/include/pixman-1 -I/usr/x86_64-w64-mingw32/include/gdk-pixbuf-2.0 -I/usr/x86_64-w64-mingw32/include/libmount -I/usr/x86_64-w64-mingw32/include/blkid -I/usr/x86_64-w64-mingw32/include/gio-unix-2.0 -I/usr/x86_64-w64-mingw32/include/atk-1.0 -I/usr/x86_64-w64-mingw32/include/at-spi2-atk/2.0 -I/usr/x86_64-w64-mingw32/include/dbus-1.0 -I/usr/x86_64-w64-mingw32/lib/dbus-1.0/include -I/usr/x86_64-w64-mingw32/include/at-spi-2.0 -pthread -o $@ $< `pkg-config --libs gtk+-3.0`

window-gtk-deps:
	cat gtk-dlls.txt | xargs -I{} find /usr/x86_64-w64-mingw32 -name {} -print | xargs -I{} cp {} ./

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
