(use clojure)

# Tinker with a potential way to draw raycast in terminal

(defn get-char [x y]
  (cond (= x 3) "M"
        (= x 2) "M"
        (and (= x 4) (> y 0) (< y 19)) "m"
        (and (= x 5) (> y 1) (< y 18)) "="
        (and (= x 6) (> y 2) (< y 17)) "-"
        :else "."))

(get-char 3 0)

(get-char 4 0)

# Each x column would be a render slice
(defn render []
  (var view "")
  (for y 0 20
    (set view (str view "\n"))
    (for x 0 79
      (set view (str view (get-char x y)))
      #(print (str (string x) ", "(string y)))
      )
    )
  view)

(-> (render) print)
