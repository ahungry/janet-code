# -*- mode: makefile -*-

# Smallest possible clean sample to build iup (Windows)

CC=gcc

CFLAGS=-Wall -std=c99 -fPIC
LFLAGS=-lm -pthread

IUP_CFLAGS=-I/usr/include/iup
IUP_LFLAGS=-liup -liupimglib

all: iup.bin

iup.bin: iup.c
	$(CC) $(CFLAGS) $(IUP_CFLAGS) $< -o $@ $(LFLAGS) $(IUP_LFLAGS)

.PHONY:
