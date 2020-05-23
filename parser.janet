(defmacro my-pp [& xs]
  ~(do
     (pp "in my special macro")
     (pp ;xs)))

(defn expand-str [s]
  (def form (parse s))
  (pp form)
  (string (macex form)))

# (expand-str "(my-pp 3)")

(def peg-form
  '{:id (some (+ (range "09") (range "az") (range "AZ") "-" "_"))
    :arg (* (any :s) :id (any :s))
    #:form (* "(" :id (any (+ :arg :form)) ")")
    :form (capture (* "(" :id (any (+ :s :form :arg)) ")"))
    :main (* (some :form))
    })

#(peg/match peg-form "(outer (middle (inner 1 2 3) (inner-2 4 5 6)))")

(defn parse-file [s]
  (def parser (parser/new))
  # (->> (slurp s)
  #      (map (fn [byte] (parser/byte parser byte))))
  (parser/consume parser (slurp s))
  (pp (parser/produce parser))
  )

#(parse-file "js.janet")

(defn rest [xs] (if (= 0 (length xs)) [] (array/slice xs 1)))

(defn try-type [x]
  (try
    (type x)
    ([err] :function)))

(defn handle-fn [f args]
  {:call f :args args})

(defn handle-atom [x] x)

(defn walk-form [y]
  (def x (macex y))
  (cond (tuple? x) (let [[f] x]
                     (handle-fn f (map walk-form (rest x))))
        :else (handle-atom x)))

(def ast
  (walk-form '(defn foo [] (pp 5))))

(defn symbol-replacements [x]
  (cond (= '+ x) :plus
        (= '- x) :minus
        (= '/ x) :slash
        (= '* x) :start
        :else x))

(defn call-replacements [x]
  (cond (number? x) (string x)
        :else (string/format "'%s'" (string (symbol-replacements x)))))

(defn ast->js [ast]
  (cond (struct? ast)
        (string/format "janet.call(%s, %s)"
                       (call-replacements (get ast :call))
                       (string/join (map ast->js (get ast :args)) ","))
        (string? ast) (string/format "'%s'" ast)
        (number? ast) (string ast)
        :else (string/format "'%s'" (string ast))))

# (ast->js (walk-form '(pp "Hello")))
#(ast->js (walk-form '(def x "Hello")))
# (ast->js (walk-form '(defn hello [] "Hello")))

(defn make-js []
  (def prelude (slurp "janet.js"))
  (def generated
    (string
     prelude
     (->>
      #(ast->js (walk-form '(do (def x 3) (pp (+ x 2)))))
      (ast->js (walk-form '(do (defn three [] (+ 1 2)) (pp (three)))))
      (string/replace-all "\n" "__nl__"))))
  (pp generated)
  (spit "generated.js" generated))

(make-js)
