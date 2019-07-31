(import clojure :as c)

(use clojure)

# Try out a PEG for matching a URL perhaps...
# https://janet-lang.org/docs/peg.html
(def peg-uri
  '{
    :any (+ (range "09") (range "az") (range "AZ") ":" "-")
    :slash (some "/")
    :node (* :slash (capture (some :any)))
    :main (some :node)
   })

(defn first-letter [s] (string/slice s 0 1))

(defn rest-letter [s] (string/slice s 1))

(defn contains? [x xs] (> (length (filter (fn [y] (= x y)) xs)) 0))

(defn is-slug-match?
  "Consider it matching.  s1 should be side with wildcard matches."
  [s1 s2]
  (if (or (= s1 s2)
          (= ":" (first-letter s1)))
    (if (= s1 s2) true {(keyword (rest-letter s1)) s2})
    nil))

# There is probably a way to use loop to go over this or something.
(defn is-uri-match?
  "Map across URIs and compare each slug.  uri1 can include wildcards."
  [uri2 uri1]
  (let [peg1 (peg/match peg-uri uri1)
             peg2 (peg/match peg-uri uri2)
             diff (map is-slug-match? peg1 peg2)]
    (if (contains? nil diff)
        nil
      (filter (fn [x] (= :struct (type x))) diff))))

# True matches
(is-uri-match?  "/foo/bar" "/foo/bar")
(is-uri-match? "/foo/bar" "/foo/:bar")

(reduce c/conj {} (is-uri-match? "/foo/hello/world" "/foo/:bar/:baz"))

# False matches
(is-uri-match? "/xfoo/bar/baz" "/foo/:xxx/baz")

(def routes
     [
      {:uri "/version"
       :f (fn [request] {:version "0.0.1"})}
      {:uri "/hello/:name/:age"
       :f (fn [request] {:message (c/str "Greetings "
                                         (c/get-in request [:slugs :name] )
                                         " - You are "
                                         (c/get-in request [:slugs :age] )
                                         " years old!"
                                         )})}
      {:uri "/:" :f (fn [req] {:error "resource not found."})}
      ])

(defn get-matching-routes [routes uri]
  (filter (fn [x] (not (= nil x)))
          (map (fn [route]
                 (let [maybe (is-uri-match? uri (get route :uri))]
                   (if maybe
                     (c/conj route {:slugs (reduce c/conj {} maybe)})
                     nil)))
               routes)))

# (get-matching-routes routes "/hello/matt/36")

(defn apply-matching-route [routes request]
  (let [{:uri uri} request
        route (first (get-matching-routes routes uri))]
    (if route
      (let [{:f f :slugs slugs} route]
        (f (c/conj request {:slugs slugs})))
      nil)))

# (apply-matching-route routes {:uri "/version"})

(apply-matching-route routes {:foo "bar" :uri "/hello/matt/36"})

(defn dispatch [req]
  (or (apply-matching-route routes req)
      {:error "404 not found"}))
