(defn show-popup []
  (def iup (IupOpen (int-ptr) (char-ptr)))
  (def label (IupLabel "Hello world from IUP."))

  # Hmm..why did it think this one was a string ?
  (def button (IupButton "OK" "NULL"))

  (def vbox (IupVbox button (int-ptr)))
  (def dialog (IupDialog vbox))

  (IupSetAttribute dialog "TITLE" "Hello World 2")

  # TODO: Would need some way to inject a janet callback via
  # a custom function that inline eval some janet code most likely...
  #(def button-exit-cb 0)
  #(IupSetCallback button "ACTION" button-exit-cb)

  (var x 5)
  (def thunk (iup-make-janet-thunk (fn []
                                     (++ x)
                                     x)))
  # (def thunk2 (iup-make-janet-thunk button "ACTION" (fn [] (+ 13 1))))

  (pp x)
  (pp thunk)
  # (pp thunk2)

  (pp (iup-call-janet-thunk thunk))
  (pp x)

  (iup-set-thunk-callback button "ACTION" (iup-make-janet-thunk (fn [] (++ x) (pp x))))

  # (pp (iup-call-janet-thunk thunk2))
  # (iup-make button "ACTION" button-exit-cb)

  (IupShowXY dialog (const-IUP-CENTER) (const-IUP-CENTER))

  (IupMainLoop)

  #(IupMessage "Hello World 1" "Hello world from IUP.")
  (IupClose))

(defn main []
  (pp "Init")
  (show-popup))
