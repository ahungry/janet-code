(import standalone :as s)
(import iup :as gui)
(import circlet_lib :as web)

(defn handler [req]
  {
   :status 200
   :headers {"Content-Type" "application/json"}
   :body 42
   })

(defn worker
  "Run the webserver in the background?"
  [parent]
  (pp "yay")
   #(s/get-ip)
  # (web/server handler 8000)
  )

(defn main [_]
  (thread/new worker)
  # (thread/new (fn [p] (s/get-ip)))
  (s/get-ip)
  (gui/main)
  (pp "Hello"))
