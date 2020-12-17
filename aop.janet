# (def - (fn new- [& args] (print :hi) (- ;args)))
# Sample to wrap a function with another function

(defmacro make-proxy-fn-around
  "Wrap function F with function G."
  [f g]
  ~(def ,f (fn proxied [& args]
             (,g ,f ;args))))

(make-proxy-fn-around + (fn [f & xs]
                          (def arity (length xs))
                          (def types (map type xs))
                          (def result (f ;xs))
                          (def ret-type (type result))
                          (pp {:arity arity
                               :types types
                               :values xs
                               :ret-type ret-type
                               :result result})
                          result))

(+ 1 2 3 4)
# prints: {:result 10 :values (1 2 3 4) :types @[:number :number :number :number] :arity 4 :ret-type :number}
# evals to: 10

(+ 1 2 (+ 3 4))
