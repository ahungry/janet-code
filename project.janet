(declare-project
  :name "mymod"
  :description "Try out building my mod."
  :author "Matthew Carter"
  :license "GPLv3"
  :url "https://github.com/ahungry/janet-code/"
  :repo "git+https://github.com/ahungry/janet-code.git")

(declare-native
  :name "mymod"
  :embedded @["mymod_lib.janet"]
  :source @["mymod.c"])

(declare-native
  :name "futures"
  :embedded @["futures_lib.janet"]
  :source @["futures.c"])

(declare-native
  :name "bench"
  :embedded @["bench_lib.janet"]
  :source @["bench.c"])

(declare-native
  :name "udp"
  #:embedded @["bench_lib.janet"]
  :cflags ["-std=gnu99" "-Wall" "-Wextra"]
  :lflags ["-lm" "-ldl" "-lpthread"]
  :source @["udp.c"])

(declare-native
  :name "tcp"
  #:embedded @["bench_lib.janet"]
  :cflags ["-std=gnu99" "-Wall" "-Wextra"]
  :lflags ["-lm" "-ldl" "-lpthread"]
  :source @["tcp.c"])

(declare-native
  :name "table"
  :cflags ["-std=gnu99" "-Wall" "-Wextra"]
  :lflags ["-lm" "-ldl" "-lpthread"]
  :source @["table.c"])

(declare-source
 :name "test"
 :source @["test.janet"])

# this 'works' (I am to the point of generating a sample png with it)
# (declare-native
#   :name "cairo"
#   :cflags ["-std=gnu99" "-Wall" "-Wextra" "-I/usr/include/cairo"
#            "-I/usr/include/glib-2.0" "-I/usr/lib/glib-2.0/include"
#            "-I/usr/lib/libffi-3.2.1/include" "-I/usr/include/pixman-1"
#            "-I/usr/include/freetype2" "-I/usr/include/libpng16"
#            "-I/usr/include/harfbuzz"]
#   :lflags ["-lm" "-ldl" "-lpthread" "-lcairo"]
#   :source @["cairo_wrap.c"])

# This has worked to get a url, follow a 302 and retrieve data over 302
(declare-native
 :name "curl"
 :cflags ["-std=gnu99" "-Wall" "-Wextra"]
 :lflags ["-lm" "-ldl" "-lpthread" "-lcurl"]
 :source @["curl_wrap_app.c"])

(declare-native
 :name "wincurl4"
 :cflags ["-std=c99" "-Wall" "-Wextra"
          "-s" "-shared"
          "-I/usr/x86_64-w64-mingw32/include/curl"
          #"amalg/janet.c"
          ]
 :lflags ["-static" "-DCURL_STATICLIB" "-lws2_32"
          "-lwinmm" "-L/usr/x86_64-w64-mingw32/lib"
          "-Wl,--subsystem,windows"
          "-l:libcurl.dll.a" "-lmingw32" "-luuid" "-lcomctl32" "-lole32" "-lcomdlg32"
          "-lssp"
          "-lm" "-pthread"]
 :source @["curl_wrap_app.c"])

# (declare-native
#  :name "wintest"
#  :clfags ["-std=c99" "-Wall" "-Wextra"
#           "-s" "-shared"
#           "-I./amalg" "amalg/janet.c"]
#  :lflags ["-lws2_32" "-lwinmm"
#           "-lmingw32" "-luuid" "-lcomctl32" "-lole32" "-lcomdlg32"
#           "-lssp"
#           "-lm" "-pthread"]
#  :source @["wintest.c"]
#  )

# (declare-native
#   :name "iup"
#   :cflags ["-std=gnu99" "-Wall" "-Wextra"
#            "-I/usr/include/iup"
#           ]
#   :lflags ["-lm" "-ldl" "-lpthread" "-liup" "-liupimglib" ]
#   :source @["iup_wrap.c"])

(phony "update-mymod" []
       (os/shell "curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.c > mongoose.c")
       (os/shell "curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.h > mongoose.h"))
