# -*- mode: makefile -*-

# Smallest possible clean sample to build curl (install from pacman)

CC=gcc

CFLAGS=-Wall -std=c99 -fPIC
LFLAGS=-lm -pthread

CURL_CFLAGS=
CURL_LFLAGS=-lcurl

all: curl.bin

curl.bin: curl.c
	$(CC) $(CFLAGS) $(CURL_CFLAGS) $< -o $@ $(LFLAGS) $(CURL_LFLAGS)

.PHONY:
