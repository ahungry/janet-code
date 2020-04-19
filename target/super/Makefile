# -*- mode: makefile -*-

# Include all the other things from various targets

CC=gcc

CFLAGS=-Wall -std=gnu99 -fPIC
LFLAGS=-lm -pthread

JANET_CFLAGS=-I./amalg
JANET_LFLAGS=-ldl

CURL_CFLAGS=
CURL_LFLAGS=-lcurl

IUP_CFLAGS=-I/usr/include/iup
IUP_LFLAGS=-liup -liupimglib

CIRCLET_CFLAGS=-I./circlet circlet/mongoose.c
CIRCLET_LFLAGS=

all: app.bin super-repl.bin

app.bin: app.c
	$(CC) $(CFLAGS) \
	$(JANET_CFLAGS) \
	$(CURL_CFLAGS) \
	$(IUP_CFLAGS) \
	$(CIRCLET_CFLAGS) \
	amalg/janet.c $< -o $@  \
	$(JANET_LFLAGS) \
	$(CURL_LFLAGS) \
	$(IUP_LFLAGS) \
	$(CIRCLET_LFLAGS) \
	$(LFLAGS)

super-repl.bin: super.c
	$(CC) $(CFLAGS) \
	$(JANET_CFLAGS) \
	$(CURL_CFLAGS) \
	$(IUP_CFLAGS) \
	amalg/janet.c $< -o $@  \
	$(JANET_LFLAGS) \
	$(CURL_LFLAGS) \
	$(IUP_LFLAGS) \
	$(LFLAGS)

.PHONY:
