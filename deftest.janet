(var cost-max 0)
(var total 0)
(var fail 0)

(defn run [cost]
  (set cost-max cost)
  (print "deftest cost level set to: " cost)
  (pp "This many pass vs fail")
  (pp (string/format "%s / %s [pass/total]" (string (- total fail)) (string total))))

(run 8)

(defmacro deftest
    [{:cost cost
            :what what} & rest]
  ~(when (>= cost-max (or ,cost 5))
     (try
      (do
          (set total (inc total))
          ,;rest)
      ([err]
       (print (string/format
               "deftest failure when testing:\n\n    '%s'\n" (or ,what "?")))
       (print "----------------------------------------------------------")
       (pp (quote ,;rest))
       (print "----------------------------------------------------------")
       (print (string/format "\n  with err: %s\n" err))
       (set fail (inc fail))
       ))))

(deftest {:cost 1 :what "Basic sanity test"}
  (assert (= 1 2 )))

(deftest {:cost 8 :what "blub"}
  (assert (= 3 2 )))

(deftest {:cost 1 :what "finally work"}
  (assert (= 2 2 )))
