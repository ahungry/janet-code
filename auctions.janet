(import deps/sqlite3 :as sql)

# Open up the db
(def db (sql/open "ahungry.db"))

(def r (sql/eval db "select count(*) as x from eqAuction"))

# Close the db
(sql/close db)

(pp r)

(def peg-remove-non-numbers
  '{:num (capture :d)
    :main (some (+ :num :D))})

(defn strip-non-numbers [s]
  (-> (peg/match peg-remove-non-numbers s)
      (string/join "")))

(strip-non-numbers "a b c123a b c45 e f g" )
