(defn mapkv [f xs] (map f (partition 2 (interleave (keys xs) (values xs)))))

(defn list->joined-table [xs]
  (def m @{})
  (map (fn [[k v]]
         (if-let [entry (get m k)
                  uniq? (not= entry v)]
           (put m k (string entry ", " v))
           (put m k v)))
       (partition 2 xs)) m)

(defn parse-headers [response]
  (let [str (get response :headers)]
    (->> (string/split "\r\n" str)
         (filter |(string/find ":" $))
         (mapcat |(string/split ":" $ 0 2))
         (map string/trim)
         # (apply table)
         list->joined-table
         (freeze))))

(parse-headers {:headers "\r\n\r\nFoo: Bar\r\nFoo: Baz\r\n"})

(defn parse-headers2 [response]
  (let [str (get response :headers)]
    (->> (string/split "\r\n" str)
         (filter |(string/find ":" $))
         (map |(map string/trim (string/split ":" $ 0 2)))
         (reduce |(let [key (first $1) value (last $1)]
                    (if-let [entry (get $ key)]
                      (set ($ key) [;entry value])
                      (put $ key [value]))
                    $) @{})

         (freeze))))


(def headers "\r\n
\r\n
Cookie-set: language=pl, expires=Sat, 15-Jul-2017 23:58:22 GMT, path=/, domain=x.com\r\n
Cookie-set: id=123 expires=Sat, 15-Jul-2017 23:58:22 GMT, path=/, domain=x.com, httponly\r\n
Content-Type: application/json\r\n
Content-Type: application/json\r\n
Foo: Bar\r\n")

#(pp headers)

(parse-headers {:headers headers})

#(parse-headers2 {:headers headers})
