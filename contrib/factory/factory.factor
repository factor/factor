USING: kernel alien compiler namespaces generic math sequences hashtables io
arrays words prettyprint concurrency process
vars rectangle x11 x concurrent-widgets ;

IN: factory

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: workspace-menu
DEFER: wm-frame?
DEFER: manage-window
DEFER: window-list
DEFER: refresh-window-list
DEFER: layout-frame
DEFER: mapped-windows
DEFER: workspace-1 DEFER: workspace-2 DEFER: workspace-3 DEFER: workspace-4
DEFER: switch-to
DEFER: update-title
DEFER: delete-frame

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: popup-window ( -- ) mouse-sensor move-window raise-window map-window ;

: popup-window% [ popup-window ] with-window-object ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: root-menu

: setup-root-menu ( -- )
  create-menu root-menu set
  "black" lookup-color root-menu get set-window-background%
  "Terminal" [ "xterm &" system ] root-menu get add-popup-menu-item
  "Emacs"    [ "emacs &" system ]          root-menu get add-popup-menu-item
  "Firefox"  [ "firefox &" system ]        root-menu get add-popup-menu-item
  "Workspaces"
    [ workspace-menu get popup-window% ] root-menu get add-popup-menu-item ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: drag-gc

: make-drag-gc ( -- GC )
create-gc dup
[ IncludeInferiors set-subwindow-mode
  GXxor set-function
  white-pixel get set-foreground ] with-gcontext ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: event frame push position ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: event-type ( -- type ) event> XAnyEvent-type ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: drag-offset ( -- offset ) position> push> v- ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-rubber-band ( <rect> -- )
root get [ drag-gc get [ draw-rect ] with-gcontext ] with-win ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! drag-move-frame
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-frame-outline ( -- )
drag-offset frame> window-position% v+ frame> window-size% <rect>
draw-rubber-band ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: drag-move-frame-loop ( -- )
next-event >event
{ { [ event-type MotionNotify = ]
    [ draw-frame-outline
      event> XMotionEvent-root-position >position
      draw-frame-outline
      drag-move-frame-loop ] }
  { [ event-type ButtonRelease = ]
    [ draw-frame-outline
      drag-offset frame> window-position% v+   frame> move-window% ] }
  { [ t ]
    [ "[drag-move-frame-loop] Ignoring event type: " write
      event-type event-type>name write terpri flush
      drag-move-frame-loop ] } }
cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: drag-move-frame ( event <wm-frame> -- )
[ >frame >event
  event> XButtonEvent-root-position >push
  event> XButtonEvent-root-position >position
  draw-frame-outline
  drag-move-frame-loop
  frame> raise-window% ]
with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! drag-size-frame
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-size-outline ( -- )
frame> window-position% position> over v- <rect> draw-rubber-band ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: drag-size-frame-loop ( -- )
next-event >event
{ { [ event-type MotionNotify = ]
    [ draw-size-outline
      event> XMotionEvent-root-position >position
      draw-size-outline
      drag-size-frame-loop ] }
  { [ event-type ButtonRelease = ]
    [ draw-size-outline
      position> frame> window-position% v- frame> resize-window%
      frame> layout-frame ] }
  { [ t ]
    [ "[drag-size-frame-loop] ignoring event" print flush
      drag-size-frame-loop ] } }
cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: drag-size-frame ( event <wm-frame> -- )
[ >frame >event
  event> XButtonEvent-root-position >position
  draw-size-outline
  drag-size-frame-loop ]
with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: move-request-x
GENERIC: move-request-y
GENERIC: move-request-position
GENERIC: execute-move-request
GENERIC: size-request-width
GENERIC: size-request-height
GENERIC: size-request-size
GENERIC: execute-size-request

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! wm-root
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-root ;

: wm-root-mask ( -- mask )
[ SubstructureRedirectMask
  SubstructureNotifyMask
  ButtonPressMask
  ButtonReleaseMask
  KeyPressMask
  KeyReleaseMask ] bitmask ;

: create-wm-root ( window-id -- <wm-root> )
dpy get swap <window> <wm-root> tuck set-delegate dup add-to-window-table
wm-root-mask over select-input% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-map-request-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: id>obj ( id -- obj )
dup window-table get hash dup [ nip ] [ drop dpy get swap <window> ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root handle-map-request-event ( event <wm-root> -- )
"handle-map-request-event called on wm-root" print flush
  drop XMapRequestEvent-window id>obj				! obj

  { { [ dup wm-frame? ]
      [ map-window% ] }

    { [ dup valid-window?% not ]
      [ "Not a valid window." print flush drop ] }

    { [ dup window-override-redirect% 1 = ]
      [ "Not reparenting: " print 
        "new window has override_redirect attribute set." print flush
        drop ] }

    { [ dup window-id window-parent+ id>obj wm-frame? ]
      [ "Window is already managed" print flush drop ] }

    { [ t ] [ window-id manage-window ] } }

  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Words for working with an XConfigureRequestEvent
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bit-test ( a b -- t-or-f ) bitand 0 = not ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-request-x? ( event -- ) XConfigureRequestEvent-value_mask CWX bit-test ;
: move-request-y? ( event -- ) XConfigureRequestEvent-value_mask CWY bit-test ;

: move-request? ( event -- ? ) dup move-request-x? swap move-request-y? or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-request-width? ( event -- )
  XConfigureRequestEvent-value_mask CWWidth bit-test ;

: size-request-height? ( event -- )
  XConfigureRequestEvent-value_mask CWHeight bit-test ;

: size-request? ( event -- )
  dup size-request-width? swap size-request-height? or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-configure-request-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root move-request-x ( event wm-root -- x )
  drop
  dup move-request-x?
  [ XConfigureRequestEvent-x ]
  [ XConfigureRequestEvent-window [ window-x ] with-win ]
  if ;

M: wm-root move-request-y ( event wm-root -- y )
  drop
  dup move-request-y?
  [ XConfigureRequestEvent-y ]
  [ XConfigureRequestEvent-window [ window-y ] with-win ]
  if ;

M: wm-root move-request-position ( event wm-root -- { x y } )
  2dup move-request-x -rot move-request-y 2array ;

M: wm-root execute-move-request ( event wm-root -- )
  dupd move-request-position swap XConfigureRequestEvent-window move-window+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root size-request-width ( event wm-root -- width )
  drop
  dup size-request-width?
  [ XConfigureRequestEvent-width ]
  [ XConfigureRequestEvent-window [ window-width ] with-win ]
  if ;

M: wm-root size-request-height ( event wm-root -- height )
  drop 
  dup size-request-height?
  [ XConfigureRequestEvent-height ]
  [ XConfigureRequestEvent-window [ window-height ] with-win ]
  if ;

M: wm-root size-request-size ( event wm-root -- { width height } )
  2dup size-request-width -rot size-request-height 2array ;

M: wm-root execute-size-request ( event wm-root -- )
  dupd size-request-size swap XConfigureRequestEvent-window resize-window+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root handle-configure-request-event ( event wm-root -- )
  over move-request? [ 2dup execute-move-request ] when
  over size-request? [ 2dup execute-size-request ] when
  drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-button-press-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: XButtonEvent-position ( event -- { x y } )
  dup XButtonEvent-x swap XButtonEvent-y 2array ;

: XButtonEvent-root-position ( event -- { x y } )
  dup XButtonEvent-x_root swap XButtonEvent-y_root 2array ;

M: wm-root handle-button-press-event ( event wm-root -- )
  drop						! event

  { { [ dup XButtonEvent-button Button1 = ]
      [ root-menu get window-map-state% IsUnmapped =
        [ XButtonEvent-root-position root-menu get move-window%
          root-menu get raise-window%
          root-menu get map-window% ]
        [ root-menu get unmap-window% ]
        if ] }

    { [ dup XButtonEvent-button Button2 = ]
      [ window-list get window-map-state% IsUnmapped =
        [ XButtonEvent-root-position window-list get move-window%
          window-list get raise-window%
          window-list get refresh-window-list
          window-list get map-window% ]
        [ window-list get unmap-window% ]
        if ] }

    { [ t ] [ "Button has no function on root window." print flush drop ] } }

  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-key-press-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: True 1 ;
: False 0 ;

: f1-keycode ( -- code ) 67 ;
: f2-keycode ( -- code ) 68 ;
: f3-keycode ( -- code ) 69 ;
: f4-keycode ( -- code ) 70 ;

: grab-keys ( -- )
f1-keycode Mod1Mask False GrabModeAsync GrabModeAsync grab-key
f2-keycode Mod1Mask False GrabModeAsync GrabModeAsync grab-key
f3-keycode Mod1Mask False GrabModeAsync GrabModeAsync grab-key
f4-keycode Mod1Mask False GrabModeAsync GrabModeAsync grab-key ;

M: wm-root handle-key-press-event ( event wm-root -- )
drop
{ { [ dup XKeyEvent-keycode f1-keycode = ] [ workspace-1 get switch-to ] }
  { [ dup XKeyEvent-keycode f2-keycode = ] [ workspace-2 get switch-to ] }
  { [ dup XKeyEvent-keycode f3-keycode = ] [ workspace-3 get switch-to ] }
  { [ dup XKeyEvent-keycode f4-keycode = ] [ workspace-4 get switch-to ] }
  { [ t ] [ "wm-root ignoring key press" print drop ] } } cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-child ;

: create-wm-child ( window-id -- <wm-child> )
dpy get swap <window> <wm-child> tuck set-delegate dup add-to-window-table ;

M: wm-child handle-property-event ( event <wm-child> -- )
  "A <wm-child> received a property event" print flush
  nip
  window-parent% window-table get hash dup [ update-title ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-frame child ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: wm-frame-mask ( -- mask )
[ SubstructureRedirectMask
  SubstructureNotifyMask
  ExposureMask
  ButtonPressMask
  ButtonReleaseMask
  PointerMotionMask
  EnterWindowMask ] bitmask ;

: create-wm-frame ( <wm-child> -- <wm-frame> )
<wm-frame> create-window-object over set-delegate dup add-to-window-table
wm-frame-mask over select-input% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update-title ( <wm-frame> -- )
dup clear-window%
{ 5 1 } swap dup wm-frame-child fetch-name% swap draw-string-top-left% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: child frame button ;

: manage-window ( window -- )
flush-dpy grab-server flush-dpy
create-wm-child dup create-wm-frame
[ child frame ]
[ "cornflowerblue" lookup-color frame> set-window-background%
  child> add-to-save-set%
  child> window-position% frame> move-window%
  0 child> set-window-border-width%
  frame> child> reparent-window%
  child> window-size% { 10 20 } v+ frame> resize-window%
  { 5 15 } child> move-window%
  "" frame> [ delete-frame ] curry create-button
  [ button ]
  [ frame> button> reparent-window%
    { 9 9 } button> resize-window%
    frame> window-width% 9 - 5 - 3 2array button> move-window%
    NorthEastGravity button> set-window-gravity%
    black-pixel get button> set-window-background% ]
  let
  PropertyChangeMask child> select-input%
  frame> map-subwindows%
  frame> map-window%
  frame> update-title
  flush-dpy 0 sync-dpy ungrab-server flush-dpy ]
let ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: destroy-window-event-match? ( event <wm-frame> -- ? )
window-id swap XDestroyWindowEvent-window = ;

M: wm-frame handle-destroy-window-event ( event <wm-frame> -- )
2dup destroy-window-event-match? [ destroy-window% drop ] [ 2drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-request-event-match? ( event <wm-frame> -- ? )
  window-id swap XMapRequestEvent-window = ;

M: wm-frame handle-map-request-event ( event <wm-frame> -- )
  2dup map-request-event-match?				! event frame ?
  [ dup wm-frame-child map-window% map-window% drop ] [ drop drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-event-match? ( event <wm-frame> -- ? )
window-id swap XMapEvent-window = ;

M: wm-frame handle-map-event ( event <wm-frame> -- )
  2dup map-event-match?
  [ dup map-window% raise-window% drop ] [ drop drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-frame handle-configure-request-event ( event frame )
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame move-request-x ( event frame -- x )
  over move-request-x?
  [ drop XConfigureRequestEvent-x ]
  [ nip window-x% ]
  if ;

M: wm-frame move-request-y ( event frame -- y )
  over move-request-y?
  [ drop XConfigureRequestEvent-y ]
  [ nip window-y% ]
  if ;

M: wm-frame move-request-position ( event frame -- { x y } )
  2dup move-request-x -rot move-request-y 2array ;

M: wm-frame execute-move-request ( event frame )
  dup -rot move-request-position swap move-window% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame size-request-width ( event frame -- width )
  over size-request-width?
  [ drop XConfigureRequestEvent-width ]
  [ nip wm-frame-child window-width% ]
  if ;

M: wm-frame size-request-height ( event frame -- height )
  over size-request-height?
  [ drop XConfigureRequestEvent-height ]
  [ nip wm-frame-child window-height% ]
  if ;

M: wm-frame size-request-size ( event frame -- size )
  2dup size-request-width -rot size-request-height 2array ;

: execute-size-request/child ( event frame )
  dup wm-frame-child -rot size-request-size swap resize-window% ;

: execute-size-request/frame ( event frame )
  dup -rot size-request-size { 10 20 } v+ swap resize-window% ;

M: wm-frame execute-size-request ( event frame )
  2dup execute-size-request/child execute-size-request/frame ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-configure-request-event ( event frame )
  over move-request? [ 2dup execute-move-request ] when
  over size-request? [ 2dup execute-size-request ] when
  drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unmap-event-match? ( event frame -- ? )
  wm-frame-child window-id swap XUnmapEvent-window = ;

M: wm-frame handle-unmap-event ( event frame )
  2dup unmap-event-match? [ unmap-window% drop ] [ drop drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-button-press-event ( event frame )
  over XButtonEvent-button				! event frame button
  { { [ dup Button1 = ] [ drop drag-move-frame ] }
    { [ dup Button2 = ] [ drop drag-size-frame ] }
    { [ dup Button3 = ] [ drop nip unmap-window% ] }
    { [ t ] [ drop drop drop ] } }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-enter-window-event ( event frame )
  nip dup wm-frame-child valid-window?%
  [ wm-frame-child >r RevertToPointerRoot CurrentTime r> set-input-focus% ]
  [ destroy-window% ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-property-event ( event frame -- )
"Inside handle-property-event" print flush 2drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-expose-event ( event frame -- )
nip dup clear-window% update-title ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: frame-position-child ( frame -- ) wm-frame-child { 5 15 } swap move-window% ;

: frame-fit-child ( frame -- )
dup window-size% { 10 20 } v- swap wm-frame-child resize-window% ;

: layout-frame ( frame -- ) dup frame-position-child frame-fit-child ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: WM_PROTOCOLS
SYMBOL: WM_DELETE_WINDOW

: delete-frame ( frame -- ) wm-frame-child window-id
[ WM_PROTOCOLS get WM_DELETE_WINDOW get send-client-message ] with-win ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Workspaces
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: switch-to

SYMBOL: current-workspace

TUPLE: workspace windows ;

: create-workspace [ ] <workspace> ;

M: workspace switch-to ( workspace -- )
  mapped-windows dup current-workspace get set-workspace-windows
  [ unmap-window+ ] each
  dup workspace-windows [ map-window+ ] each
  current-workspace set-global ;

SYMBOL: workspace-1
SYMBOL: workspace-2
SYMBOL: workspace-3
SYMBOL: workspace-4

create-workspace workspace-1 set-global
create-workspace workspace-2 set-global
create-workspace workspace-3 set-global
create-workspace workspace-4 set-global

workspace-1 get current-workspace set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: workspace-menu

: setup-workspace-menu ( -- )
  create-menu workspace-menu set
  "black" lookup-color workspace-menu get set-window-background%
  "Workspace 1"
    [ workspace-1 get switch-to ] workspace-menu get add-popup-menu-item
  "Workspace 2"
    [ workspace-2 get switch-to ] workspace-menu get add-popup-menu-item
  "Workspace 3"
    [ workspace-3 get switch-to ] workspace-menu get add-popup-menu-item
  "Workspace 4"
    [ workspace-4 get switch-to ] workspace-menu get add-popup-menu-item ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: invalid-frame? ( <wm-frame> -- ? )
wm-frame-child window-id valid-window?+ not ;

: remove-invalid-frames ( -- )
window-table get hash-values [ wm-frame? ] subset [ invalid-frame? ] subset
[ window-id window-table get remove-hash ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! window-list
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: window-list

: setup-window-list ( -- )
  create-menu window-list set-global
  "black" lookup-color window-list get set-window-background%
  300 window-list get set-menu-item-width ;

: not-transient? ( frame -- ? ) wm-frame-child get-transient-for-hint% not ;

: add-window-to-list ( window-list frame -- window-list )
  dup				! window-list frame frame
  wm-frame-child		! window-list frame child
  fetch-name%			! window-list frame name-or-f
  dup				! window-list frame name-or-f name-or-f
  [ ] [ drop "*untitled*" ] if	! window-list frame name
  swap				! window-list name frame
  [ map-window% ]		! window-list name frame [ map-window% ]
  curry				! window-list name action
  pick				! window-list name action window-list
  add-popup-menu-item ;

: refresh-window-list ( window-list -- )
  dup window-children% [ destroy-window+ ] each
  clean-window-table
  remove-invalid-frames
  window-table get hash-values [ wm-frame? ] subset
  [ not-transient? ] subset
  [ add-window-to-list ] each
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: window-is-mapped? ( window -- ? ) window-map-state+ IsUnmapped = not ;

: mapped-windows ( -- [ a b c d ... ] )
  root get window-children+ [ window-is-mapped? ] subset ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: manage-existing-windows ( -- ) mapped-windows [ manage-window ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-factory ( dpy-string -- )
  initialize-x
  [ "X11 : error-handler called" print flush ] set-error-handler
  root get [ make-drag-gc ] with-win drag-gc set
  root get [ black-pixel get set-window-background clear-window ] with-win
  root get create-wm-root
  root get [ grab-keys ] with-win
  "WM_PROTOCOLS" False intern-atom WM_PROTOCOLS set
  "WM_DELETE_WINDOW" False intern-atom WM_DELETE_WINDOW set
  "cornflowerblue" lookup-color menu-enter-color set
  "white" lookup-color menu-leave-color set
  setup-root-menu
  setup-window-list
  setup-workspace-menu
  manage-existing-windows
  [ concurrent-event-loop ] spawn ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: shells USE: listener : factory f start-factory listener ;