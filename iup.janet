# Hmm..why did it think this one was a string ?
(var x 0)

(defn show-popup []
  (def iup (IupOpen (int-ptr) (char-ptr)))
  (def label (IupLabel "Hello world from IUP."))

  (def button (IupButton (string/format "Button clicked %d times" x) "NULL"))

  (def vbox (IupVbox button (int-ptr)))
  (def dialog (IupDialog vbox))

  (IupSetAttribute dialog "TITLE" "Hello World 2")

  # TODO: Would need some way to inject a janet callback via
  # a custom function that inline eval some janet code most likely...
  #(def button-exit-cb 0)
  #(IupSetCallback button "ACTION" button-exit-cb)

  (def thunk-recursive-popups
       (iup-make-janet-thunk
        (fn []
            (++ x)
            (spit "iup-thunk.log" (string/format "%d\n" x) :a)
          # Essentially keeps opening windows, sort of neat...
          (show-popup)
             # (IupRedraw button 0)
          )))

  (iup-set-thunk-callback
   button "ACTION"
   thunk-recursive-popups)

  # (pp (iup-call-janet-thunk thunk2))
  # (iup-make button "ACTION" button-exit-cb)

  (IupShowXY dialog (const-IUP-CENTER) (const-IUP-CENTER))

  # (IupMainLoop)

  #(IupMessage "Hello World 1" "Hello world from IUP.")
  # (IupClose)
  )

(defn main []
  (pp "Init")
  (show-popup)
  (IupMainLoop)
  (IupClose))
