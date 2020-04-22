#!/bin/sh

top=$(pwd)

rm -fr build/janet
mkdir -p build

git clone \
    --depth=1 \
    --branch=feature/Add-more-builtins \
    https://github.com/ahungry/janet.git build/janet

# Copy down the custom wrap files
# cp curl_wrap_app.c    build/janet/src/
# cp iup_wrap.c         build/janet/src/
# cp circlet/mongoose.c build/janet/src/
# cp circlet/circlet.c  build/janet/src/
# cp sqlite3/main.c     build/janet/src/
# cp json/json.c        build/janet/src/

cd build/janet
make -j8

# cd $top

# # We need to ensure the amalg build is 4 levels deep
# amalg=amalg/a/b/c

# mkdir -p $amalg
# cp build/janet/build/janet.c     ./$amalg/
# cp build/janet/build/janet.h     ./$amalg/
# cp build/janet/build/janetconf.h ./$amalg/
