# Create a new object called Car with two methods, :say and :honk.
(def Car
 @{:type "Car"
   :color "gray"
   :say (fn [self msg] (print "Car says: " msg))
   :honk (fn [self] (print "beep beep! I am " (self :color) "!"))})

# Red Car inherits from Car
(def RedCar
 (table/setproto @{:color "red"} Car))

(:honk Car) # prints "beep beep! I am gray!"
(:honk RedCar) # prints "beep beep! I am red!"

# Pass more arguments
(:say Car "hello!") # prints "Car says: hello!"
