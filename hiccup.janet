(defn rest
  "Clojure like rest."
  [col]
  (array/slice col 1))

(defn mapkeys
  "Apply function F to each key/value tuple in map M."
  [f m]
  (map (fn [k] (f [k (get m k)])) (keys m)))

(defn make-attributes [m]
  (->
   (mapkeys (fn [[k v]] (string/format "%s=\"%s\"" (string k) (string v))) m)
   (string/join " ")))

# (macex1 ~(html-helper identity))
(defmacro html-helper
  "Inline some statement we reuse a lot."
  [f]
  ~(string/format "%s%s" (,f el) (or (html (rest xs)) "")))

(defn html [xs]
  (when (> (length xs) 0)
    (let [[el next] xs]
      (cond
        (and (keyword? el)
             (struct? next))
        (string/format "<%s %s>\n%s\n</%s>\n" (string el)
                       (html [next])
                       (html (rest (rest xs))) (string el))

        (keyword? el)
        (string/format "<%s>\n%s\n</%s>\n" (string el) (or (html (rest xs)) "") (string el))

        (struct? el)
        (html-helper make-attributes)

        (tuple? el)
        (html-helper html)

        (string? el)
        (html-helper identity)

        ""
        ))))

(defn footer [year]
  (html [:div {:id "footer"} (string/format "copyright %s" year)]))

# (spit
#  "/tmp/web.html"
#  (html
#   [:p
#    [:b {:id "Bolded"} "Not bad..."]
#    (footer "2020")
#    ]))

(html
 [:p
    [:b {:id "Bolded"} "Not bad..." "hah"]
  (footer "2020")
 ])
