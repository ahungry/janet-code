(defn interlace-symbols [ks]
  (zipcoll ks (map symbol ks)))

(interlace-symbols [:a :b])

(defmacro with-keys [ks m & rest]
  ~(let [,(interlace-symbols ks) ,m] ,;rest))

(macex1 '(with-keys [:a :b] {:a 1 :b 2} (pp a)))

(with-keys [:a :b] {:a 1 :b 2} (pp a))

(defn example [m]
  (with-keys [:x :y] m
             (pp (+ x y))))

(example {:x 3 :y 4})

(defn interlace-symbols [ks]
  (zipcoll ks (map symbol ks)))

(defmacro with-keys [ks m & rest]
  ~(let [,(interlace-symbols ks) ,m] ,;rest))

(defn example [m]
  (with-keys [:x :y] m
             (pp (+ x y))))

(example {:x 3 :y 4}) # -> 7

(defn mapmap [f xs]
  (def keys (keys xs))
  (def vals (values xs))
  (map (fn [i] (f [(get keys i) (get vals i)]))
       (range (length vals))))

(mapmap (fn [[k v]] (pp k)) {:a 1 :b 2})
