(import standalone :as s)
(import iup :as gui)

(defn main [_]
  (s/get-ip)
  (gui/main)
  (pp "Hello"))
