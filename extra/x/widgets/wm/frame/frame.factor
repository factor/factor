
USING: kernel io combinators namespaces quotations arrays sequences
       math math.vectors
       x11.xlib x11.constants
       mortar slot-accessors
       geom.rect
       x x.gc x.widgets
       x.widgets.button
       x.widgets.wm.child
       x.widgets.wm.frame.drag.move
       x.widgets.wm.frame.drag.size ;

IN: x.widgets.wm.frame

SYMBOL: <wm-frame>

<wm-frame> <widget> { "child" "gc" "last-state" } accessors define-simple-class

<wm-frame> "create" !( id <wm-frame> -- wm-frame ) [
  new-empty
  swap <wm-child> new* >>child
  <gc> new* "white" <-- set-foreground >>gc

  SubstructureRedirectMask
  ExposureMask bitor
  ButtonPressMask bitor
  ButtonReleaseMask bitor
  ButtonMotionMask bitor
  EnterWindowMask bitor
  ! experimental masks
  SubstructureNotifyMask bitor
  >>mask

  <- init-widget
  "cornflowerblue" <-- set-background
  dup $child <- position <-- move
  dup $child over <-- reparent drop
  <- position-child
  <- fit-to-child
  <- make-frame-button

  <- map-subwindows
  <- map
] add-class-method

SYMBOL: WM_PROTOCOLS
SYMBOL: WM_DELETE_WINDOW

: init-atoms ( -- )
"WM_PROTOCOLS" 0 intern-atom WM_PROTOCOLS set
"WM_DELETE_WINDOW" 0 intern-atom WM_DELETE_WINDOW set ;

<wm-frame> {

"fit-to-child" !( wm-frame -- wm-frame )
  [ dup $child <- size { 10 20 } v+ <-- resize ]

"position-child" !( wm-frame -- wm-frame ) 
  [ dup $child { 5 15 } <-- move drop ]

"set-child-size" !( wm-frame size -- frame )
  [ >r dup $child r> <-- resize drop <- fit-to-child ]

"set-child-width" !( wm-frame width -- frame )
  [ >r dup $child r> <- set-width drop <- fit-to-child ]

"set-child-height" !( wm-frame height -- frame )
  [ >r dup $child r> <- set-height drop <- fit-to-child ]

"adjust-child" !( wm-frame -- wm-frame )
  [ dup $child over <- size { 10 20 } v- <-- resize drop ]

"update-title" !( wm-frame -- wm-frame )
  [ <- clear
    dup >r
    ! dup $gc { 5 1 } pick $child <- fetch-name <--- draw-string/top-left
    dup $gc { 5 11 } pick $child <- fetch-name <---- draw-string
    r> ]

"delete-child" !( wm-frame -- wm-frame ) [
  dup $child WM_PROTOCOLS get WM_DELETE_WINDOW get <--- send-client-message
  drop ]

"drag-move" !( event wm-frame -- ) [ <wm-frame-drag-move> new* ]

"drag-size" !( event wm-frame -- ) [ <wm-frame-drag-size> new* ]

"make-frame-button" !( frame -- frame ) [
<button> new*
  over <-- reparent
  "" >>text
  over [ <- unmap drop ]        curry >>action-1
  over [ <- delete-child drop ] curry >>action-3
  { 9 9 } <-- resize
  NorthEastGravity <-- set-gravity
  "white" <-- set-background
  over <- width 9 -  5 -  3 2array <-- move
  drop ]

! !!!!!!!!!! Event handlers !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"handle-enter-window" !( event wm-frame -- )
  [ nip $child RevertToPointerRoot CurrentTime <--- set-input-focus drop ]

"handle-expose" !( event wm-frame -- ) [ nip <- clear <- update-title drop ]

"handle-button-press" !( event wm-frame -- ) [
  over XButtonEvent-button
  { { [ dup Button1 = ] [ drop <- drag-move ] }
    { [ dup Button2 = ] [ drop <- drag-size ] }
    { [ t ] [ 3drop ] } }
  cond ]

"handle-map" !( event wm-frame -- )
  [ "<wm-frame> handle-map :: ignoring values" print flush 2drop ]

"handle-unmap" !( event wm-frame -- ) [ nip <- unmap drop ]

"handle-destroy-window" !( event wm-frame -- ) [
  nip dup $child <- remove-from-window-table drop
  <- remove-from-window-table <- destroy ]

"handle-configure-request" !( event frame -- ) [
  { { [ over dup CWX? swap CWY? and ]
      [ over XConfigureRequestEvent-position <-- move ] }
    { [ over CWX? ] [ over XConfigureRequestEvent-x <-- set-x ] }
    { [ over CWY? ] [ over XConfigureRequestEvent-y <-- set-y ] }
    { [ t ] [ "<wm-frame> handle-configure-request :: move not requested"
              print flush ] } }
  cond

  { { [ over dup CWWidth? swap CWHeight? and ]
      [ over XConfigureRequestEvent-size <-- set-child-size ] }
    { [ over CWWidth? ]
      [ over XConfigureRequestEvent-width <-- set-child-width ] }
    { [ over CWHeight? ]
      [ over XConfigureRequestEvent-height <-- set-child-height ] }
    { [ t ]
      [ "<wm-frame> handle-configure-request :: resize not requested"
      	print flush ] } }
  cond
  2drop ]

} add-methods

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: wm-frame-maximize ( wm-frame -- wm-frame )
<- save-state
{ 0 0 } <-- move
dup $dpy $default-root <- size
  <-- resize
<- adjust-child 
<- raise ;

: wm-frame-maximize-vertical ( wm-frame -- wm-frame )
0 <-- set-y
dup $dpy $default-root <- height
  <-- set-height
<- adjust-child ;

<wm-frame> "save-state" !( wm-frame -- wm-frame ) [
  dup <- position
  over <- size
    <rect> new
  >>last-state
] add-method

<wm-frame> "restore-state" !( wm-frame -- wm-frame ) [
  dup $last-state $pos <-- move
  dup $last-state $dim <-- resize
  <- adjust-child
] add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

