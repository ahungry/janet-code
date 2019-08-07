# https://lodev.org/cgtutor/raycasting.html

(def map-width 24)
(def map-height 24)

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

(def screen-resolution {:x 79 :y 20})

# the width
(var w 79)

(defn iterate-x-slices []
  (for i 0 w
    (do
      (var camera-x (- (* 2 (/ x w)) 1))
      (var ray-dir-x (+ dir-x (* plane-x camera-x)))
      (var ray-dir-y (+ dir-y (* plane-y camera-x)))
      # Which box we're in
      (var map-x pos-x)
      (var map-y pos-y)
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
      (var side nil) # Was NS or EW wall?


        )))
