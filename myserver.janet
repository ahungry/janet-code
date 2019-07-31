(import deps/circlet :as circlet)
(import deps/json :as json)
(import deps/sqlite3 :as sqlite3)

(import router)

# headers
# body
# uri
# method
# protocol
# connection
# query-string
(defn myserver
  "A simple HTTP server"
  [req]
  (pp req)
  (let [res (router/dispatch req)]
    (print "Res was: ")
    (pp res)
    # (print (kvs req))
    # (-> (keys req) print)
    (map print (keys req))
    (print (get req :uri))
    {:status 200
             :headers {"Content-Type" "application/json"}
             :body (json/encode res)}))

# json/encode does not work recursively - need to solve.

(def x @{:a 1 :b 2})
(def j1 (json/encode x))
(def j2 (json/decode j1))

(print (get x :a))

(defn add1 [n] (+ 1 n))
(->> [3 4 5] (map identity) (map add1) (map print))

# (defn add-1 [n] (+ 1 n))
# (defn add-2 [n] (+ 2 n))
# (def add-3 (comp add-1 add-2))

# (myserver nil)

# Test some import stuff...
(import foo :as bar)

(print (bar/hello))

(import fizz/buzz)

(fizz/buzz/hello)

(circlet/server myserver 8000)
