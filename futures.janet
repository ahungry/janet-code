(import build/futures :as f)

(use build/bench)

(doc f/future)
(doc f/realize)
(doc f/realize-all)

(defn sleep-future [n]
  (f/future
   (fn []
       (os/sleep n)
       n)))

(defn test-realize-all []
  (let [futures (map sleep-future (range 5))]
    (f/realize-all futures)))

# Will resolve in 4 seconds, not in 10. :)
(time (test-realize-all))

(defn test-futures []
  (let [futures (map sleep-future (range 10))]
    (os/sleep 2)
    # Now, a couple of them should be resolved.
    (map f/realize futures)
    ))

(test-futures)

# Lets see how futures are doing with memory testing
(defn many-futures [n]
  (let [futures (map (fn [x] (f/future (fn [] x))) (range n))]
    (f/realize-all futures)))

(defn many-no-futures [n]
  (let [futures (map (fn [x] x) (range n))]
    futures))

# Using that many forks and linked structs in mmap module
# took 7.8 MB, 2.6 cpu/sec
(time (many-futures 1000))

# Using it without a fork / future ends up taking
# 0 MB, 0.000462 cpu/sec - so, obviously only use this when the bottleneck
# tends to be a wait on some external process (db query, tcp request etc.)
(time (many-no-futures 1000))

(time nil)
