(import build/tcp :as tcp)

# (def sock (tcp/make-sock "127.0.0.1" 8000))
(def sock (tcp/make-sock "localhost" 8000))

(pp sock)

(defn get-version [sock]
  (tcp/send-sock sock "GET /version HTTP/1.1\n\n\n")
  (tcp/read-sock sock))

(print (get-version sock))

(tcp/unmake-sock sock)
