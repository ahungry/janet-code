# https://janet-lang.org/docs/threads.html

(defn worker
  "Runs a thread that will take a number and add one to it."
  [parent]
  (print "Waiting for message...")
  (def msg (thread/receive math/inf))
  (print "Got the message: " msg)
  (os/sleep 3)
  (:send parent (+ 1 msg)))

(defn call-worker
  [n]
  (let [thread (thread/new worker)]
    (:send thread n)
    (print "call-worker result: " (thread/receive 10))))

(call-worker 5)
