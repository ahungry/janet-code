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

(defn html [xs]
  # Need this to be internal or it can't reference html
  (defn make-tag [x xs]
    (let [s (string x)
          [next] xs]
      (if (struct? next)
        (string/format "<%s %s>\n%s\n</%s>\n" s (html [next]) (html (rest xs)) s)
          (string/format "<%s>\n%s\n</%s>\n" s (or (html xs) "") s))))

  (when (> (length xs) 0)
    (let [el (first xs)]
      (cond
       (keyword? el)
       (make-tag el (rest xs))

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
    [:b {:id "Bolded"} "Not bad..."]
  (footer "2020")
 ])
