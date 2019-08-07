(use clojure)
# https://lodev.org/cgtutor/raycasting.html

(def screen-resolution {:x 100 :y 40})

(def world-map
  @[
    @[1 1 1 1 1 1 1 1 1 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 0 0 0 0 0 0 0 0 1]
    @[1 1 1 1 1 1 1 1 1 1]
   ])

# Player location
(var pos-x 5)
(var pos-y 5)

# Player direction (vector)
(var dir-x -1)
(var dir-y 0)

# Camera plane (perpendicular like a T to the player dir, where this is the top of T)
(var plane-x 0)
(var plane-y 0.66) # Smaller, so smaller FOV like a FPS (more zoomed out)

# the width
(var w (get screen-resolution :x))
(var h (get screen-resolution :y))

(var move-speed 3)
(var rot-speed 3)

(defn move-up [& _]
  (set pos-x (+ pos-x (* dir-x move-speed)))
  (set pos-y (+ pos-y (* dir-x move-speed)))
  )

(defn move-down [& _]
  (set pos-x (- pos-x (* dir-x move-speed)))
  (set pos-y (- pos-y (* dir-x move-speed)))
  )

(defn rotate-left [& _]
  (var old-dir-x dir-x)
  (set dir-x (- (* dir-x (math/cos (* 1 rot-speed)))
                (* dir-y (math/sin (* 1 rot-speed)))))
  (set dir-y (+ (* old-dir-x (math/sin (* 1 rot-speed)))
                (* dir-y (math/cos (* 1 rot-speed)))))
  (var old-plane-x plane-x)
  (set plane-x (- (* plane-x (math/cos (* 1 rot-speed)))
                  (* plane-y (math/sin (* 1 rot-speed)))))
  (set plane-y (+ (* old-plane-x (math/sin (* 1 rot-speed)))
                  (* plane-y (math/cos (* 1 rot-speed)))))
  {:dir-x dir-x
   :dir-y dir-y
   :plane-x plane-x
   :plane-y plane-y})

(defn rotate-right [& _]
  (var old-dir-x dir-x)
  (set dir-x (- (* dir-x (math/cos (* -1 rot-speed)))
                (* dir-y (math/sin (* -1 rot-speed)))))
  (set dir-y (+ (* old-dir-x (math/sin (* -1 rot-speed)))
                (* dir-y (math/cos (* -1 rot-speed)))))
  (var old-plane-x plane-x)
  (set plane-x (- (* plane-x (math/cos (* -1 rot-speed)))
                  (* plane-y (math/sin (* -1 rot-speed)))))
  (set plane-y (+ (* old-plane-x (math/sin (* -1 rot-speed)))
                  (* plane-y (math/cos (* -1 rot-speed)))))
  {:dir-x dir-x
   :dir-y dir-y
   :plane-x plane-x
   :plane-y plane-y})

(defn iterate-x-slices []
  (var ret @[])
  (for x 0 w
    (do
      (var camera-x (- (* 2 (/ x w)) 1))
      (var ray-dir-x (+ dir-x (* plane-x camera-x)))
      (var ray-dir-y (+ dir-y (* plane-y camera-x)))
      # Which box we're in
      (var map-x (math/floor pos-x))
      (var map-y (math/floor pos-y))
      # Length of ray from current position to next x or y-side
      (var side-dist-x nil)
      (var side-dist-y nil)
      # Length of ray from one x or y-side to next x or y-side
      (var delta-dist-x (math/abs (/ 1 ray-dir-x)))
      (var delta-dist-y (math/abs (/ 1 ray-dir-y)))
      (var perp-wall-dist nil)
      # What direction to step in x or y-direction (either +1 or -1)
      (var step-x 0)
      (var step-y 0)
      (var hit 0)
      (var side nil)         # Was NS or EW wall?

      (print "dbg1")

      (if (< ray-dir-x 0)
        (do
          (set step-x -1)
          (set side-dist-x (* (- pos-x map-x) delta-dist-x)))
        (do
          (set step-x 1)
          (set side-dist-x (* (+ map-x (- 1.0 pos-x)) delta-dist-x))))

      (if (< ray-dir-y 0)
        (do
          (set step-y -1)
          (set side-dist-y (* (- pos-y map-y) delta-dist-y)))
        (do
          (set step-y 1)
          (set side-dist-y (* (+ map-y (- 1.0 pos-y)) delta-dist-y))))

      (print "dbg2")

      # Perform DDA
      (var while-iter 0)
      (var while-max 100)

      (while (and (= hit 0) (< while-iter while-max))
        (set while-iter (inc while-iter))
        (if (< side-dist-x side-dist-y)
          (do
            (set side-dist-x (+ side-dist-x delta-dist-x))
            (set map-x (+ map-x step-x))
            (set side 0))
          (do
            (set side-dist-y (+ side-dist-y delta-dist-y))
            (set map-y (+ map-y step-y))
            (set side 1))
          )

        (print "dbg3")

        # Check if ray has hit a wall
        (when (> (or (get (or (get world-map map-x) @[]) map-y) 0) 0)
          (set hit 1)
          )
        )

      (print "dbg4")

      # Calculate distance on projected camera direction (Euclidean distance gives fisheye effect)
      (if (= side 0)
        (set perp-wall-dist (/ (+ (- map-x pos-x) (/ (- 1 step-x) 2)) ray-dir-x))
        (set perp-wall-dist (/ (+ (- map-y pos-y) (/ (- 1 step-y) 2)) ray-dir-y))
        )

      (print "Right before LH")

      (var line-height (/ h perp-wall-dist))
      (array/push ret line-height)
      ))
  ret
  )

(iterate-x-slices)

(rotate-right)

# My stuff for rendering in Ascii

(defn get-char [texture height]
  (case texture
    1 (cond (> height 20) "M"
            (> height 18) "#"
            (> height 16) "#"
            (> height 14) "="
            (> height 12) "-"
            (> height 10) "\""
            (> height 8) "'"
            (> height 6) "^"
            (> height 4) "`"
            "-")
    " "))

(defn pad-array
  "Ensures we focus in center of screen the slice of wall."
  [n x]
  (math/floor (/ (- x n) 2)))

(defn make-array-of-height
  "Produce an array of height (draw a Y-slice)."
  [height max-height]
  (var n (min height max-height))
  (var x max-height)
  (pp "maoh had input as:")
  (pp n)
  (pp x)
  (var ret (array/new x))
  (for i 0 x (put ret i 0))
  (let [pad (pad-array n x)]
    (for i pad (+ pad n) (put ret i 1))
    )
  ret
  )

(make-array-of-height 2 10)

(defn make-xy-array
  "Take an x and y dimension and produce an array to fill out.
This would be derived based on global state computed from which way
the user is looking and what things they are intersecting.

wall-heights should be an array of equal length to x."
  [wall-heights y]
  (map (fn [x] (make-array-of-height x y)) wall-heights))

(iterate-x-slices)

(defn get-slices []
  (-> (iterate-x-slices)
      (make-xy-array h)))

(get-slices)

(defn render []
  (var slice-heights (iterate-x-slices))
  (var slices (make-xy-array slice-heights h))
  (var view "")
  (for y 0 h
    (set view (str view "\n"))
    (for x 0 w
      (let [point (-> slices x y)]
        (set view (str view (get-char point (x slice-heights))))
        )
      )
    )
  view)

(defn test []
  (for i 0 30
    (os/sleep 0.05)
    (rotate-right)
    (print (render))))

#(test)
