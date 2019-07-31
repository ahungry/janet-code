(defmacro time [& r]
  ~(ftime (fn [] ,;r)))
