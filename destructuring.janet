(defn foo [m]
  (let [{:name name :age age} m]
    (print "Hello " name " you are " age)))

(defn foo2 [{:name name :age age}]
  (print "Hello \n\n" name " you are " age)
  45)

(foo {:name "Matt" :age 36})

(foo2 {:name "Matt" :age 36})

(get {:x 1 :y 2} :y)
