(defn version [] "0.0.1")

(defn futures-pending?
  "See if there are any futures pending in the list."
  [futures]
  (> (count (fn [x] (= :PENDING (realize x))) futures) 0))

(defn realize-all
  "Realize all futures that are pending."
  [futures]
  (while (futures-pending? futures)
    (os/sleep 0.05))
  (map realize futures))
