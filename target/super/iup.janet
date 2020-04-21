# Hmm..why did it think this one was a string ?
(var x 0)
(var y 0)

(defn kw->upper [k]
  (if (keyword? k)
      (string/ascii-upper (string k))
    k))

(defn iup-attributes [ih m]
  (map (fn [k]
         (IupSetAttribute
          ih
          (kw->upper k)
          (kw->upper (get m k))))
       (keys m)))

(defn show-popup []
  (def iup (IupOpen (int-ptr) (char-ptr)))
  (def label (IupLabel "Hello world from IUP."))
  (def label2 (IupLabel "Windows 7 doesn't show images atm..."))

  (def button (IupButton (string/format "Button clicked %d times" y) "NULL"))
  (def button2 (IupButton "Close" "NULL"))
  (def file-dialog (IupFileDlg))

  (iup-attributes
   file-dialog
   {
    :dialogtype :open
    :title "Test open files"
    #:filter ""
    #:filter "FILTER = \"*.janet\", FILTERINFO = \"Janet Files\""
    })

  (IupSetAttribute button2 "IMAGE" "logo.bmp")

  (def vbox (IupVbox button (int-ptr)))

  (def multitext (IupText "NULL"))

  # https://webserver2.tecgraf.puc-rio.br/iup/en/func/iupdraw.html
  (def canvas (IupCanvas "NULL"))
  (iup-set-thunk-callback
   canvas "ACTION"
   (fn []
       (IupDrawBegin canvas)
       (IupSetAttribute canvas "DRAWCOLOR" "255 255 255")
       (IupSetAttribute canvas "DRAWSTYLE" "FILL")
       (IupDrawRectangle canvas 0 0 x x)
       (IupDrawImage canvas "logo.bmp" 0 0 100 100)
       (IupDrawEnd canvas)
       (const-IUP-DEFAULT)
       ))

  (IupAppend vbox label)
  (IupAppend vbox label2)
  (IupAppend vbox button2)
  (IupAppend vbox multitext)
  (IupAppend vbox canvas)

  (iup-attributes
   multitext
   {
    :multiline :yes
    :expand :yes
    })

  (IupSetAttribute vbox "ALIGNMENT" "ACENTER")
  (IupSetAttribute vbox "GAP" "10")
  (IupSetAttribute vbox "MARGIN" "10x10")

  (def dialog (IupDialog vbox))

  (def item-open (IupItem "Open" "NULL"))
  (iup-set-thunk-callback
   item-open "ACTION"
   (fn []
     # Show the selection
     (IupPopup file-dialog
               (const-IUP-CURRENT)
               (const-IUP-CURRENT))
     # See what thing we got back...
     (if (= -1 (IupGetInt file-dialog "STATUS"))
       (pp "Cancelled file dialog")
       (let [name (IupGetAttributeAsString file-dialog "VALUE")]
         (pp "Opening")
         (print (string/format "%s" name)))
       )
       ))

  (def item-save (IupItem "Save" "NULL"))
  (iup-set-thunk-callback
   item-save "ACTION"
   (fn []
       (spit "gui-test-save.txt" (IupGetAttributeAsString multitext "VALUE"))
       (int-ptr)))
  (def item-exit (IupItem "Exit" "NULL"))
  (iup-set-thunk-callback item-exit "ACTION" (fn [] (const-IUP-CLOSE)))
  (def file-menu (IupMenu item-open (int-ptr)))
  (IupAppend file-menu item-save)
  (IupAppend file-menu item-exit)
  (def sub-menu (IupSubmenu "File" file-menu))
  (def menu (IupMenu sub-menu (int-ptr)))

  (IupSetAttributeHandle dialog "MENU" menu)

  (IupSetAttribute dialog "TITLE" "Hello World 2")

  # TODO: Would need some way to inject a janet callback via
  # a custom function that inline eval some janet code most likely...
  #(def button-exit-cb 0)
  #(IupSetCallback button "ACTION" button-exit-cb)

  (def thunk-recursive-popups
    # (iup-make-janet-thunk)
       (fn []
           (++ y)
         #(spit "iup-thunk.log" (string/format "%d\n" x) :a)
         # Essentially keeps opening windows, sort of neat...
         # (show-popup)
         # (IupRedraw button 0)
         # (IupAppend vbox button)
         # (IupRedraw vbox 0)
         # (show-popup)
           (IupSetAttribute button "TITLE" (string/format "Button clicked %d times" y))
         # (IupSetAttribute button "VISIBLE" "NO")
         # (IupRedraw button 1)
           ))

  (def timer (IupTimer))
  (IupSetAttribute timer "TIME" "100")
  (iup-set-thunk-callback
   timer "ACTION_CB"
   (fn [] (++ x)
       (IupSetAttribute
        label "TITLE"
        (string/format "%d loop counter" x))
       (IupRedraw canvas 0)
       ))
  (IupSetAttribute timer "RUN" "yes")

  (iup-set-thunk-callback
   button "ACTION"
   thunk-recursive-popups)

  (iup-set-thunk-callback
   button2 "ACTION"
   (fn [] (const-IUP-CLOSE)))

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
