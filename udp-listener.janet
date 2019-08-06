(use build/bench)
(use build/futures)
(import build/udp :as udp)
(use clojure)

(defn handler [s]
  (let [out (str "We got an s: " s)]
    (print out)
    out))

# If we need to have shared memory/state, we probably need to keep track
# by using the disk, otherwise we will be effectively blocked / have to kill process
# to abort it.
(defn keep-listening? []
  (try
    (= "t" (-> (slurp "/tmp/janet.listen") string))
    ((error e) false)))

(defn listen-on-udp
  "Listen on a port (12346) for inbound traffic, process it and respond on 12345
with the processed result."
  []
  (do
    (spit "/tmp/janet.listen" "t")
    (let [port 12346
          f (partial udp/send-string "127.0.0.1" 12345)]
      (while (keep-listening?)
        (-> (udp/listen 12346) handler f)))))

(defn listen-on-udp-bg []
  (future (fn [] (listen-on-udp))))
