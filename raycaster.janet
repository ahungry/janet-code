(use clojure)

# http://www.playfuljs.com/a-first-person-engine-in-265-lines/
# Tinker with a potential way to draw raycast in terminal

# So, if we do a grid 0 to 79, we have 80 walls to render
# This means, we would draw that many rects, and each one should determine height of rectangle.

(defn get-char [texture]
  (case texture
    1 "M"
    "."))

(defn pad-array
  "Ensures we focus in center of screen the slice of wall."
  [n x]
  (math/floor (/ (- x n) 2)))

(defn make-array-of-height
  "Produce an array of height (draw a Y-slice)."
  [n x]
  (var ret (array/new x))
  (for i 0 x (put ret i 0))
  (let [pad (pad-array n x)]
    (for i pad (+ pad n) (put ret i 1))
    )
  ret
  )

(make-array-of-height 14 20)

(defn make-xy-array
  "Take an x and y dimension and produce an array to fill out."
  [x y]
  (do
    (var ret (array/new x))
    (for ix 0 x
      (put ret ix (make-array-of-height 5 y)))
    ret))

(def arr (make-xy-array 5 10))

(-> arr 0 2)

# Each x column would be a render slice
(defn render []
  (var slices (make-xy-array 79 20))
  (var view "")
  (for y 0 20
    (set view (str view "\n"))
    (for x 0 79
      (let [point (-> slices x y)]
        (set view (str view (get-char point)))
        )
      #(print (str (string x) ", "(string y)))
      )
    )
  view)

(-> (render) print)
