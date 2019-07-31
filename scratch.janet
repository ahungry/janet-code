(use build/bench)
(use build/futures)
(use clojure)

(defn times-3 [n] (* 3 n))

(defn add-1 [n] (+ 1 n))

(defn sum [a b] (+ a b))

(def f1 (comp times-3 add-1))

# 30 as expected
(f1 9)

(def f2 (compose times-3 sum))

(f2 5 5)

(print "Hello world")

(do
    (print "Hello")
    (print "World")
  5)

(map add-1 [3 4 5])

(defn make-sleepy-fiber [n]
  (fiber/new (fn [] (os/sleep n) n)))

(defn test-fiber []
  (let [fibers (map make-sleepy-fiber (range 5))]
    # Fibers would all be resolving their sleeps concurrently
    # So that the overall call time here would be 5 or so seconds, not 15 seconds.
    (os/sleep 2.0)
    (map fiber/status fibers)))

# (test-fiber)
