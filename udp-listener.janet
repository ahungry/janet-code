(use build/bench)
(use build/futures)
(import build/udp :as udp)
(use clojure)

(var input-buf (buffer/new 1))
(var cx 0)
(var cy 0)


(defn add-color
  "Add a terminal color to the buffer."
  [b]
  (buffer/push-byte b 0x1b)
  (buffer/push-string b "[36m ")
  b)

(defn cursor-goto []
  )

(def input-map
  {"\xEB" :ARROW_DOWN
     "\xEA" :ARROW_UP
     "\xE8" :ARROW_LEFT
     "\xE7" :ARROW_RIGHT
  })

(defn self-insert [s]
  (buffer/push-string input-buf s))

(defn move-cursor []
  (let [buf (buffer/new 1)]
    (buffer/push-byte buf 0x1b)
    (buffer/format buf "[%s;%sH" (string cy) (string cx))))

(defn move-up [_] (set cy (dec cy)))
(defn move-down [_] (set cy (inc cy)))
(defn move-left [_] (set cx (dec cx)))
(defn move-right [_] (set cx (inc cx)))

(defn key-to-action [s]
  (let [kw (or (get input-map s) s)]
    (case kw
      :ARROW_DOWN move-down
      :ARROW_UP move-up
      :ARROW_LEFT move-left
      :ARROW_RIGHT move-right
      self-insert)))

(key-to-action "\xB8")

(defn handler [s]
  (do
    (let [f (key-to-action s)]
      (f s) # Each key press should have an action
      (pp input-buf)
      (buffer input-buf (move-cursor))
      )))

# If we need to have shared memory/state, we probably need to keep track
# by using the disk, otherwise we will be effectively blocked / have to kill process
# to abort it.
(defn keep-listening? []
  (try
    (= "t" (-> (slurp "/tmp/janet.listen") string))
    ((error e) false)))

(keep-listening?)

(defn listen-on-udp
  "Listen on a port (12346) for inbound traffic, process it and respond on 12345
with the processed result.

Remove file /tmp/janet.listen to break out of the listen loop."
  []
  (do
    (spit "/tmp/janet.listen" "t")
    (let [port 12346
          f (partial udp/send-string "127.0.0.1" 12345)]
      (while (keep-listening?)
        (-> (udp/listen 12346) handler string f)))))

(defn listen-on-udp-bg []
  (future (fn [] (listen-on-udp))))

(defn add-color
  "Add a terminal color to the buffer."
  [b]
  (buffer/push-byte b 0x1b)
  (buffer/push-string b "[36m ")
  b)

(defn test-send [s]
  (let [b (buffer/new 1)]
    (-> b add-color (buffer/push-string s))
    #(put b 0 0x1b)
    #(buffer/push-string b "[34m ")
    #(buffer/push-string b s)
    (udp/send-string "127.0.0.1" 12345 (string b))))

(test-send "Color test sent from udp-listener.janet")
