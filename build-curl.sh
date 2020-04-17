#!/bin/bash

# This script will download a curl and build the static archive
# to be used with static linking in the standalone binary for GNU/Linux.

top=$(pwd)

version=curl-7.69.1

mkdir -p tmp/curl
cd tmp/curl
wget https://curl.haxx.se/download/$version.tar.gz
tar xzvf $version.tar.gz

cd $version

./configure --disable-shared --enable-static --prefix=tmp/curl --disable-ldap --disable-sspi --without-librtmp --disable-ftp --disable-file --disable-dict --disable-telnet --disable-tftp --disable-rtsp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-smb --without-libidn --enable-ares

make -j4

cd $top

find tmp/curl -name libcurl.a -exec cp {} $top/libcurl-nix-x86_64.a \;

cd $top
