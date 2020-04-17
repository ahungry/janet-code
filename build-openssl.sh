#!/bin/bash

# This script will download an openssl and build the static archive
# to be used with static linking in the standalone binary for GNU/Linux.
top=$(pwd)

git clone --depth 1 git@github.com:openssl/openssl.git

cd openssl
./config no-shared
make -j8
