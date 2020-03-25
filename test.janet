# Could use os/environ to pull out a setting for this?

(var instant-mode false)
(var instant-cost 10)
(var cost-max 0)
(var total 0)
(var fail 0)
(var out-buf (buffer/new 1))

(var tests @[])

(def eval-apply (comp eval apply))

(defn instant [n]
  (set instant-cost n)
  (set instant-mode true))

(defn defer [] (set instant-mode false))

(defn prin-now [s]
  (unless instant-mode
    (prin s)
    (file/flush stdout)))

(defn run [cost]
  (set cost-max cost)
  (set total 0)
  (set fail 0)
  (set out-buf (buffer/new 1))
  (if instant-mode
    (do
        (map eval-apply tests)
        (prin out-buf))
    (do
      (printf "deftest results <cost: %s>:\n" (string cost))
      (prin "  [")
      (map eval-apply tests)
      (print "]\n")
      (prin out-buf)
      (print (string/format "%s/%s [pass/total]" (string (- total fail)) (string total))))))

# (map eval-apply (identity tests))

(defn deftest
  [{:cost cost
    :what what} & rest]
  (def t
    (fn []
      (if (>= cost-max (or cost 5))
         (try
           (do
             (prin-now ".")
             (set total (inc total))
             (eval ;rest))
           ([err]
            (prin-now "f")
            (with-dyns
              [:out out-buf]
              (print (string/format
                      "Failed <%s> of the form:" (or what "?")))
              (prin "   ")
              (map pp rest)
              (print (string/format "due to error: %s\n" err))
              (set fail (inc fail)))
            ))
         (prin-now "x")
         )))
  (array/push tests t)
  (when instant-mode
    (run instant-cost)
    (set tests @[]))
  )

(defmacro test
  [& rest]
  ~(quote (do ,;rest)))

(defmacro eq [ex & rest]
  ~(quote (assert (= ,ex ,;rest))))



# (test-test)
