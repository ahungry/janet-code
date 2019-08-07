#!/bin/sh

/usr/local/bin/janet /app/udp-rc-listener.janet >/dev/null 2>&1 &

rawterm 12345 127.0.0.1 12346
