(defn mapkv [f xs] (map f (partition 2 (interleave (keys xs) (values xs)))))
