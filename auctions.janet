(import deps/sqlite3 :as sql)

# Open up the db
(def db (sql/open "ahungry.db"))

(def r (sql/eval db "select count(*) as x from eqAuction"))

# Close the db
(sql/close db)

(pp r)
