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

(def dungeon
  @[
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 1 1 1 0 0 0 0 0 0]
    @[0 1 1 1 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
    @[0 0 0 0 0 0 0 0 0 0]
   ])

(def player @{:x 3 :y 3 :direction 0})

(defn set-x [n] (put player :x n))
(defn set-y [n] (put player :y n))
(defn set-rot [n] (put player :direction n))

(defn make-no-wall []
  @{:length2 10000})

(defn get-step-dx [run x]
  (if (> run 0)
    (math/floor (+ x 1))
    (math/ceil (- (- x 1) x))))

(defn get-step-dy [rise run dx] (* dx (/ rise run)))

(defn make-step [rise run x y inverted]
  (if (= 0 run) (make-no-wall)
      (let [dx (get-step-dx run x)
            dy (get-step-dy rise run dx)]
        @{:x (if inverted (+ y dy) (+ x dx))
          :y (if inverted (+ x dx) (+ y dy))
          :length2 (+ (* dx dx) (* dy dy))})
      ))

(def dungeon-size 10)

(defn get-xy [x y]
  (let [xf (math/floor x)
        yf (math/floor y)]
    (if (or (< x 0)
            (> x (dec dungeon-size))
            (< y 0)
            (> y (dec dungeon-size)))
      -1
      (get (get dungeon xf) yf)
      )))

(defn rc-inspect [point angle range]
  (let [sin (math/sin angle)
            cos (math/cos angle)]
    (fn [step shift-x shift-y distance offset]
        (let [dx (if (< cos 0) shift-x 0)
                 dy (if (< sin 0) shift-y 0)]
          (put step :height (get-xy (- (get step :x) dx)
                                    (- (get step :y) dy)))
          (put step :distance (+ distance (math/sqrt (get step :length2))))
          (if shift-x
              (put step :shading (if (< cos 0) 2 0))
            (put step :shading (if (< sin 0) 2 1))
            )
          (put step :offset (- offset (math/floor offset)))
          step
          ))))

(defn ray [point angle range]
  (let [sin (math/sin angle)
        cos (math/cos angle)]
    (fn [origin]
      (let [step-x (make-step sin cos (get origin :x) (get origin :y) false)
            step-y (make-step cos sin (get origin :y) (get origin :x) true)
            next-step (if (< (get step-x :length2)
                             (get step-y :length2))
                        ((rc-inspect point angle range) step-x 1 0 (get origin :distance) (get step-x :y))
                        ((rc-inspect point angle range) step-y 0 1 (get origin :distance) (get step-y :x)))
           ]
        (if (> (get next-step :distance) range)
          @[origin]
          @[origin ;((ray point angle range) next-step)])
        ))))

(defn raycast [point angle range]
  (let [fray (ray point angle range)]
    (fray @{:x (get point :x)
            :y (get point :y)
            :height 0
            :distance 0})))


(def atx (get-atx 2 2))

(def angle (math/atan2 atx 0.8))

(identity player)

(raycast player angle 10)

(defn get-atx [ix x] (- (/ ix x) 0.5))

(defn make-xy-array
  "Take an x and y dimension and produce an array to fill out.
This would be derived based on global state computed from which way
the user is looking and what things they are intersecting."
  [x y]
  (do
    (var ret (array/new x))
    (for ix 0 x
      (let [atx (get-atx ix x)
                focal-length 0.8
                angle (math/atan2 atx focal-length)
                casted-ray (raycast player (+ (get player :direction) angle) 1)
                ]
        (pp casted-ray)
        (put ret ix
             (make-array-of-height
              4
              # The height of the ray being cast I guess...
              #(get casted-ray :height)
              y))))
    ret))

(make-xy-array 10 10 )

(make-array-of-height 4 10)

# (def arr (make-xy-array 5 10))
# (-> arr 0 2)

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
