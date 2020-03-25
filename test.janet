(var cost-max 0)
(var total 0)
(var fail 0)
(var out-buf (buffer/new 1))

(def tests @[])

(def eval-apply (comp eval apply))

(defn prin-now [s]
  (prin s)
  (file/flush stdout))

(defn run [cost]
  (set cost-max cost)
  (printf "deftest results <cost: %s>:\n" (string cost))
  (prin "  [")
  (map eval-apply tests)
  (print "]\n")
  (prin out-buf)
  (print (string/format "%s/%s [pass/total]" (string (- total fail)) (string total))))


# (map eval-apply (identity tests))

(defmacro deftest
  [{:cost cost
    :what what} & rest]
  (array/push
   tests
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
        ))))

(deftest {:cost 1 :what "Basic sanity test"}
  (os/sleep 0.1)
  (assert (= 1 2 )))

(deftest {:cost 9 :what "blub"}
  (os/sleep 0.1)
  (assert (= 3 2 )))

(deftest {:cost 1 :what "finally work"}
  (os/sleep 0.1)
  (assert (= 2 2 )))

(run 8)
