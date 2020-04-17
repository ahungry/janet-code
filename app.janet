(import standalone :as s)
(import iup :as gui)

(defn main []
  (s/get-ip)
  (gui/main)
  (pp "Hello"))
