(import test :as t)

(defn test-test []
  (t/deftest {:cost 1 :what "Basic sanity test"}
             (t/test (os/sleep 0.1)
                     (assert (= 1 2 ))))

  (t/deftest {:cost 3 :what "Addition"}
             (t/test (os/sleep 0.1)
                     (assert (= 3 (+ 1 3)))))

  (t/deftest {:cost 9 :what "blub"}
             (t/test
              (os/sleep 0.1)
              (assert (= 3 2 ))))

  (t/deftest {:cost 1 :what "finally work"}
             (t/test
              (os/sleep 0.1)
              (assert (= 2 2 ))))

  (t/run 8)
  )

(test-test)
