#!/bin/sh

#set -x

rm -fr deps
mkdir -p deps

for f in $(find janet_modules -name '*.so' -print); do
    path=$f
    name=$(echo $path | cut -d'/' -f5)

    cp $path deps/$name
done
