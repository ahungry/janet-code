(use build/bench)
(use build/futures)
(use clojure)

(var x 9)

(def fut1 (future (fn []
                    x)))

(realize fut1)

(defn test-future-forking []
  (var y 1)
  (let [fut1 (future (fn [] (set y 5) y))
        rel1 (do (os/sleep 0.2) (realize fut1))]
    {:y y :rel1 rel1}))

# Evals to: {:rel1 5 :y 1}
(test-future-forking)
# This means any side-effects/state alters in the future are not in the present.
# This also means you cannot push from within to the outer in any way other than return
# values/computations, but you never have to worry about acquiring a lock on things you change..

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
