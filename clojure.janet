# Clojure like shims.

(defn str [& r] (string/join r))

(defn conj
  "Clojure like conj (sorta)."
  [& r]
  (table/to-struct (apply merge r)))

(defn concat
  "Clojure like concat."
  [& r]
  (->> (reduce array/concat @[] r)
       (apply tuple)))

(defn rest
  "Clojure like rest."
  [col]
  (array/slice col 1))

(defn get-in
  "Get a nested property path from a map."
  [m ks]
  (reduce get m ks))

(defn get-some
  "Like get-in, but just go as far as possible in the path."
  [m ks]
  (let [maybe (get-in m ks)]
    (if maybe
        maybe
        (get-in m (reverse (rest (reverse ks)))))))

(defn make-sleepy-fiber [n]
  (fiber/new (fn [] (os/sleep n) n)))

(defn test-fiber []
  (let [fibers (map make-sleepy-fiber (range 5))]
    # Fibers would all be resolving their sleeps concurrently
    # So that the overall call time here would be 5 or so seconds, not 15 seconds.
    (os/sleep 2.0)
    (map fiber/status fibers)))

# (test-fiber)
