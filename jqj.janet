# Super simple 'jq' like tool/approach

# It runs about 10x faster at the moment...

# Run this with:
#   time echo '{"person": {"user":"Matt", "pass": "fake"}}' | janet -s -q ./jqj.janet  person user

(def x @{"user" "Matt" "pass" "fake"})

(import deps/json :as json)

(def json (-> (slurp "/dev/stdin") json/decode))
(def query (-> (dyn :args) (array/slice 1)))
(def result (reduce get json query))

(print (json/encode result))
