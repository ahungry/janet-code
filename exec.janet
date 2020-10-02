# (defn whoami []
#   (var out-buf (buffer/new 1))
#   (var err-buf (buffer/new 1))
#   (os/execute ["/usr/bin/whoami"]) :p {:out out-buf :err err-buf}
#   (pp "The out buffer is")
#   (pp out-buf)
#   out-buf)

# (pp (whoami))

# (def f (file/temp))
# (os/execute ["/usr/bin/whoami"] :p {:out f})
# (:flush f)
# (:seek f :set 0)
# (def outbuf (:read f :all))

# (pp outbuf)

# From gitter
(defn shell
  "Get result of os/execute."
  [& args]
  (with [f (file/temp)]
    (os/execute args :p {:out f :err f})
    (:seek f :set 0)
    (:read f :all)))
