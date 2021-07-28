(varfn foo [] nil)
(varfn bar [] nil)

(varfn foo [n]
  (if (< n 5)
    (bar n)
    n))

(varfn bar [n]
  (foo (+ 1 n)))

(pp (bar 0))
(pp (foo 3))

(defmacro defun [name doc & rest]
  ~(defn ,name ,(eval doc) ,;rest))

(defun goodbye
  (string/join
   ["Goodbye" "World"] "\n")
  []
  32)

(doc goodbye)
