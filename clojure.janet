; Clojure like shims.

(defn str [& r] (string/join r))

(defn conj
  "Clojure like conj (sorta)."
  [& r]
  (table/to-struct (apply merge r)))

(defn concat
  "Clojure like concat."
  [& r]
  (->> (reduce array/concat #[] r)
       (apply tuple)))

(defn rest
  "Clojure like rest."
  [col]
  (array/slice col 1))

(defn get-in
  "Get a nested property path from a map."
  [m ks & def]
  (try
    (reduce get m ks)
    ((error e) (or (first def) nil))))

(get-in {} [:a :b] 9)
(get-in {:a {:b 3} } [:a :b] 10)

(defn get-some
  "Like get-in, but just go as far as possible in the path."
  [m ks]
  (let [maybe (get-in m ks)]
    (if maybe
        maybe
      (get-in m (reverse (rest (reverse ks)))))))

(defn comp
  "The built-in comp only accepts unary args for f(g(x)), we want g to be any arity.

Returns f(g(x1,...))."
  [& fs]
  (fn [& r]
      (let [fns (array @fs)
                g (array/pop fns)
                init (apply g r)]
        (reduce (fn [h f] (f h)) init fns))))
