# https://janet-lang.org/docs/threads.html

# Sample of a parent thread tracking busyness of child threads

(defn worker
  [parent]
  (def m (thread/receive math/inf))
  (os/sleep (m :sleep-for))
  (:send parent {:id (m :id) :slept-for (m :sleep-for)}))

(defn call-worker
  [x]
  (def threads @[])
  # Fire off X threads
  (for n 0 x
    (let [thread (thread/new worker)]
      (array/push threads @{:id n :t thread :busy true})
      (:send thread {:id n :sleep-for (math/floor (* 5 (math/random)))})))
  (var rec 0)
  (while (> x rec)
    (def res (thread/receive 10))
    (pp res)
    (def child-thread (get threads (res :id)))
    (pp child-thread)
    (put child-thread :busy false)
    (set rec (inc rec))
    (pp threads)))

(call-worker 3)
