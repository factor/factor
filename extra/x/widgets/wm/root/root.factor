
USING: kernel io combinators namespaces arrays assocs sequences math
       x11.xlib
       x11.constants
       vars mortar slot-accessors
       x x.keysym-table x.widgets x.widgets.wm.child x.widgets.wm.frame ;

IN: x.widgets.wm.root

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: <wm-root>

<wm-root>
  <widget>
  { "keymap" } accessors
define-simple-class

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: wm-root

: create-wm-root ( -- )
  <wm-root> new-empty
    dpy> >>dpy
    dpy> $default-root $id >>id
    SubstructureRedirectMask >>mask
    <- add-to-window-table
    SubstructureRedirectMask <-- select-input
    H{ } clone >>keymap
  >wm-root ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: find-in-table ( window -- object )
dup >r $id   dpy get $window-table   at r> or ;

: circulate-focus ( -- )
dpy get $default-root <- children
[ find-in-table ] map [ <- mapped? ] subset   dup length 1 >
[ reverse dup first <- lower drop
  second <- raise
  dup <wm-frame> is? [ $child ] [ ] if
  RevertToPointerRoot CurrentTime <--- set-input-focus drop ]
[ drop ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: managed? ( id -- ? )
dpy get $window-table values [ <wm-child> is? ] subset [ $id ] map member? ;

: event>keyname ( event -- keyname ) lookup-keysym keysym>name ;

: event>state-and-name ( event -- array )
dup XKeyEvent-state swap event>keyname 2array ;

: resolve-key-event ( keymap event -- item ) event>state-and-name swap at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<wm-root> {

"handle-map-request" !( event wm-root -- ) [
  { { [ over XMapRequestEvent-window managed? ]
      [ "<wm-root> handle-map-request :: window already managed" print flush
      	2drop ] }
    { [ t ] [ drop XMapRequestEvent-window <wm-frame> <<- create drop ] } }
  cond ]

"handle-unmap" !( event wm-root -- ) [ 2drop ]

"handle-key-press" !( event wm-root -- )
  [ $keymap swap resolve-key-event call ]

"grab-key" !( wm-root modifiers keyname -- wm-root modifiers keyname ) [
  3dup name>keysym keysym-to-keycode swap rot
  False GrabModeAsync GrabModeAsync grab-key ]

"set-key-action" !( wm-root modifiers keyname action -- wm-root ) [
  >r <--- grab-key r>
  -rot 2array pick $keymap set-at ]

"handle-configure-request" !( event wm-root -- ) [
  $dpy over XConfigureRequestEvent-window <window> new ! event window
  { { [ over dup CWX? swap CWY? and ]
      [ over XConfigureRequestEvent-position <-- move ] }
    { [ over CWX? ] [ over XConfigureRequestEvent-x <-- set-x ] }
    { [ over CWY? ] [ over XConfigureRequestEvent-y <-- set-y ] }
    { [ t ] [ "<wm-root> handle-configure-request :: move not requested"
      	      print flush ] } }
  cond

  { { [ over dup CWWidth? swap CWHeight? and ]
      [ over XConfigureRequestEvent-size <-- resize ] }
    { [ over CWWidth? ] [ over XConfigureRequestEvent-width <-- set-width ] }
    { [ over CWHeight? ] [ over XConfigureRequestEvent-height <-- set-height ] }
    { [ t ] [ "<wm-root> handle-configure-request :: resize not requested"
      	      print flush ] } }
  cond
  2drop ]

} add-methods