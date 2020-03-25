# Could use os/environ to pull out a setting for this?

(var instant-mode true)
(var instant-cost 10)
(var cost-max 0)
(var total 0)
(var fail 0)
(var out-buf (buffer/new 1))

(var tests @[])

(def eval-apply (comp eval apply))

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

(defmacro deftest
  [{:cost cost
    :what what} & rest]
  (def t
    (fn []
      ~(if (>= cost-max (or ,cost 5))
         (try
           (do
             (prin-now ".")
             (set total (inc total))
             ,;rest)
           ([err]
            (prin-now "f")
            (with-dyns
              [:out out-buf]
              (print (string/format
                      "Failed <%s> of the form:" (or ,what "?")))
              (prin "   ")
              (pp (quote ,rest))
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

(deftest {:cost 1 :what "Basic sanity test"}
  (os/sleep 0.1)
  (assert (= 1 2 )))

(deftest {:cost 3 :what "Addition"}
  (os/sleep 0.1)
  (assert (= 3 (+ 1 3))))

(deftest {:cost 9 :what "blub"}
  (os/sleep 0.1)
  (assert (= 3 2 )))

(deftest {:cost 1 :what "finally work"}
  (os/sleep 0.1)
  (assert (= 2 2 )))

(run 8)
