(import standalone :as s)
(import iup :as gui)
(import circlet_lib :as web)
(import auctions :as a)

(defn handler [req]
  (pp "Got a request..")
  (pp req)
  {
   :status 200
   :headers {"Content-Type" "application/json"}
   :body "42"
   })

(defn worker
  "Run the webserver in the background?"
  [parent]
  (pp "yay")
  (s/get-ip)
  #(pp "Running webserver on port 12005, feel free to make a request..")
  #(web/server handler 12005)
  )

(defn main [_]
  (thread/new worker)
  # (thread/new (fn [p] (s/get-ip)))
  (pp (a/exec-db))
  #(s/get-ip)
  (pp (json/encode {:a 1 :b 2}))
  (gui/main)
  #(web/server handler 8000)
  (pp "Hello"))
