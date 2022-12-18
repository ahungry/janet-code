(var *typecheck-mode* false)

(defn checker [fn-name types args]
  (when (> (length types) 1)
    (for i 0 (- (length types) 1)
      (assert (= (get types i) (last (get args i)))
              (string/format "Type mismatch in %s, ex: %s, got: %s"
                             (string fn-name)
                             (string (get types i)) (string (last (get args i)))))))
  types)

(defmacro deft [name args types body]
  ~(defn ,name ,args
     (if *typecheck-mode*
       (checker ,name ,types ,args)
       ,body)))

(deft get-num [] [:num] 30)
(deft string->num [n] [:str :num] (scan-number n))
(deft num->string [n] [:num :str] (string/format "%d" n))
(num->string (get-num))
# With *typecheck-mode* true
#   error: Type mismatch in <function string->num>, ex: str, got: num
# With *typecheck-mode* false
#   error: bad slot #0, expected string|symbol|keyword|buffer, got 30
(string->num (get-num))
