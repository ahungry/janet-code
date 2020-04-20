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
  (pp curl-easy-init)
  (pp "Hi from thread")
  # (os/sleep 10)
  #(eval  '(pp "HELLO FROM THE THREAD"))
  # (eval '(s/get-ip))
  # (web/server handler 8000)
  )

(defn main [_]
  (pp curl-easy-init)
  (thread/newx worker)
  (os/sleep 1)
  # (thread/new (fn [p] (s/get-ip)))
  #(s/get-ip)
  #(gui/main)
  #(web/server handler 8000)
  (pp "Hello"))
