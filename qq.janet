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

(defn publish
  "Publish an EVENT with PAYLOAD to QUEUE."
  [queue event payload]
  (let [f-list (or (get queue event) @[])]
    (map |($0 payload) f-list)))

(defn print-1 [x]
  (pp "I am the print-1 call")
  (pp x))

(defn print-2 [x]
  (pp "I am the print-2 call")
  (pp x))

(subscribe queue ::hello print-1)
(subscribe queue ::hello print-2)

(publish queue ::hello "World")
