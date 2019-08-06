(defn version [] "0.0.1")

(defn future-pending? [x]
  (= :PENDING (realize x)))

(defn futures-pending?
  "See if there are any futures pending in the list."
  [futures]
  (> (count future-pending? futures) 0))

(defn deref
  "Similar to Clojure deref - wait until we can realize the future."
  [x]
  (while (future-pending? x)
    (os/sleep 0.05))
  (realize x))

(defn realize-all
  "Realize all futures that are pending."
  [futures]
  (while (futures-pending? futures)
    (os/sleep 0.05))
  (map realize futures))
