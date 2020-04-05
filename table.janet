(import build/table :as bt)

(def hmm (bt/make-table 1 2))

(pp "good")

(pp (get "x" hmm))
(pp (get :x hmm))
