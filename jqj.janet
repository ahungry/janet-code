# Super simple 'jq' like tool/approach

# It runs about 10x faster at the moment...

# Run this with:
#   time echo '{"person": {"user":"Matt", "pass": "fake"}}' | janet -s -q ./jqj.janet  person user

(import deps/json :as json)
(import clojure)

(def x @{"user" "Matt" "pass" "fake"})

(def json (-> (slurp "/dev/stdin") json/decode))
(def query (-> (dyn :args)
               clojure/rest
               ))

(pp json)
(pp query)

(def result (clojure/get-in json query nil))
#(def result (get json (first query)))
#(def result (get json "user"))

(pp result)
