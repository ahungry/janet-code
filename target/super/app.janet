(import standalone :as s)
(import iup :as gui)
(import circlet_lib :as web)

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
  (s/get-ip)
  (pp "Hi from thread")
  # (os/sleep 10)
  #(eval  '(pp "HELLO FROM THE THREAD"))
  # (eval '(s/get-ip))
  #(web/server handler 8001)
  )

(defn main [_]
  (pp curl-easy-init)
  (thread/new worker)
  # (thread/new (fn [p] (s/get-ip)))
  #(s/get-ip)
  #(os/sleep 9)
  (gui/main)
  #(web/server handler 8001)
  (pp "Hello"))
