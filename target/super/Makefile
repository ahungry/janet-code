# -*- mode: makefile -*-

# Smallest possible clean sample to build curl (install from pacman)

CC=gcc

CFLAGS=-Wall -std=gnu99 -fPIC
LFLAGS=-lm -pthread

JANET_CFLAGS=-I./amalg
JANET_LFLAGS=-ldl

CURL_CFLAGS=
CURL_LFLAGS=-lcurl

IUP_CFLAGS=-I/usr/include/iup
IUP_LFLAGS=-liup -liupimglib

all: super.bin

super.bin: super.c
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
