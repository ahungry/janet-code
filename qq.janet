#!/usr/local/bin/janet

# A simple queue system

(def queue @{})

(defn subscribe
  "When QUEUE receives EVENT, apply F to the payload."
  [queue event f]
  (unless (get queue event)
    (put queue event @[]))
  (let [f-list (get queue event)]
    (array/push f-list f)))

(defn print-1 [parent]
  (let [{:queue queue
         :event event
         :payload payload} (thread/receive math/inf)]
    (os/sleep 1)
    (pp "I am the print-1 call")
    (pp payload)))

(defn print-2 [parent]
  (let [{:queue queue
         :event event
         :payload payload} (thread/receive math/inf)]
    (os/sleep 1)
    (pp "I am the print-2 call")
    (pp payload)))

(defn publish
  "Publish an EVENT with PAYLOAD to QUEUE."
  [queue event payload]
  (let [f-list (or (get queue event) @[])]
    (map (fn [f] (:send (thread/new f)
                        {:queue queue
                         :event event
                         :payload payload}))
         f-list)))

(defn inc-1 [p]
  (let [{:queue queue
         :event event
         :payload payload} (thread/receive math/inf)]
    (os/sleep 1)
    (pp "In inc-1")
    (pp payload)
    (unless (>= payload 3)
      (publish queue ::counter (+ 1 payload)))))

(subscribe queue ::hello print-1)
(subscribe queue ::hello print-2)

(subscribe queue ::counter inc-1)

(publish queue ::hello "World")
(publish queue ::counter 0)
(publish queue ::counter 0)
