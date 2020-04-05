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

(phony "update-mymod" []
       (os/shell "curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.c > mongoose.c")
       (os/shell "curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.h > mongoose.h"))
