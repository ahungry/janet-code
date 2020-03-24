(defn rest
  "Clojure like rest."
  [col]
  (array/slice col 1))

(defn make-attributes [m]
  (->
   (let [ks (keys m)]
     (map (fn [k]
              (let [v (get m k)
                      sk (string k)
                      sv (string v)
                      ]
                (string/format "%s=\"%s\"" sk sv)))
          ks))
   (string/join " ")))

(defmacro html-helper [f]
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
       (string/format "%s%s" (make-attributes el) (or (html (rest xs)) ""))

       (tuple? el)
       (string/format "%s%s" (html el) (or (html (rest xs)) ""))

       (string? el)
       (string/format "%s%s" el (or (html (rest xs)) ""))

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
