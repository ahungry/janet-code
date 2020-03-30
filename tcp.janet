(import build/tcp :as tcp)

#(def sock (tcp/make-sock "127.0.0.1" 8000))
(def sock (tcp/make-sock "httpbin.org" 80))

(defn get-version [sock]
  # (tcp/send-sock sock "GET /version HTTP/1.0\n\n\n")
  (tcp/send-sock sock "GET /ip HTTP/1.0\n\n\n")
  (tcp/read-sock sock))

(print (get-version sock))

(tcp/unmake-sock sock)
