
USING: kernel io alien alien.c-types namespaces threads
       arrays sequences assocs math vars combinators.lib
       x11.constants x11.events x11.xlib mortar slot-accessors geom.rect ;

IN: x

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: <display>

SYMBOL: <window>

! SYMBOL: dpy

VAR: dpy

<display>
  { "ptr"
    "name"
    "default-screen"
    "default-root"
    "default-gc"
    "black-pixel"
    "white-pixel"
    "colormap" 
    "window-table" } accessors
define-independent-class

<display> "create" !( name <display> -- display ) [
  new-empty swap >>name
  dup $name dup [ string>char-alien ] [ ] if XOpenDisplay
  dup [ >>ptr ] [ "XOpenDisplay error" throw ] if
  dup $ptr XDefaultScreen >>default-screen
  dup $ptr XDefaultRootWindow dupd <window> new >>default-root
  dup $ptr over $default-screen XDefaultGC >>default-gc
  dup $ptr over $default-screen XBlackPixel >>black-pixel
  dup $ptr over $default-screen XWhitePixel >>white-pixel
  dup $ptr over $default-screen XDefaultColormap >>colormap 
  H{ } clone >>window-table
  [ <- start-event-loop ] in-thread
] add-class-method

{ "id" } accessors drop

DEFER: check-window-table

<display> {

"add-to-window-table" !( display window -- )
  [ dup $id rot $window-table set-at ]

"remove-from-window-table" !( display window -- )
  [ $id swap $window-table delete-at ]

"next-event" !( display event -- display event )
  [ over $ptr over XNextEvent drop ]

"events-queued" !( display mode -- n ) [ >r $ptr r> XEventsQueued ]

"concurrent-next-event" !( display event -- display event )
  [ over QueuedAfterFlush <-- events-queued 0 >
    [ <-- next-event ] [ 100 sleep <-- concurrent-next-event ] if ]

"event-loop" !( display event -- )
[ <-- concurrent-next-event
  2dup >r >r
  dup XAnyEvent-window rot $window-table at dup
  [ <- handle-event ] [ 2drop ] if
  r> r>
  <-- event-loop ]

"start-event-loop" !( display -- ) [ "XEvent" <c-object> <-- event-loop ]

"flush" !( display -- display ) [ dup $ptr XFlush drop ]

"pointer-window" !( display -- window ) [
  dup $ptr
  over $default-root $id
  0 <Window>
  0 <Window> dup >r
  0 <int>
  0 <int>
  0 <int>
  0 <int>
  0 <uint>
    XQueryPointer drop
  r> *Window <window> new
  check-window-table ]

} add-methods

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<window> { "dpy" "id" } accessors define-independent-class

: create-window ( -- window ) <window> new-empty <- init-window ;

: create-window-from-id ( dpy id -- window ) <window> new ;

: check-window-table ( window -- window )
  dup $id
  over $dpy $window-table
    at
  swap or ;

<window> "init-window"
  !( window -- window )
  [ dpy get
      >>dpy
    dpy get $ptr
    dpy get $default-root $id
    0 0 100 100 0
    dpy get $black-pixel
    dpy get $white-pixel
    XCreateSimpleWindow
      >>id ]
add-method

! <window> new-empty <- init

<window> "raw"
  !( window -- dpy-ptr id )
  [ dup $dpy $ptr swap $id ]
add-method

<window> "move"
  !( window point -- window )
  [ >r dup <- raw r> first2 XMoveWindow drop ]
add-method

<window> "set-x" !( window x -- window ) [
  over <- y 2array <-- move
] add-method

<window> "set-y" !( window y -- window ) [ 
  over <- x swap 2array <-- move
] add-method

<window> "flush"
  !( window -- window )
  [ dup $dpy <- flush drop ]
add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3 - Window Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 3.3 - Creating Windows

<window> "destroy" !( window -- window )
  [ dup <- raw XDestroyWindow drop ]
add-method

<window> "map"
  !( window -- window )
  [ dup <- raw XMapWindow drop ]
add-method

<window> "map-subwindows"
  !( window -- window )
  [ dup <- raw XMapSubwindows drop ]
add-method

<window> "unmap"
  !( window -- window )
  [ dup <- raw XUnmapWindow drop ]
add-method

<window> "unmap-subwindows"
  !( window -- window )
  [ dup <- raw XUnmapSubwindows drop ]
add-method

! 3.7 - Configuring Windows

<window> "resize"
  !( window size -- window )
  [ >r dup <- raw r> first2 XResizeWindow drop ]
add-method

<window> "set-width"
  !( window width -- window )
  [ over <- height 2array <-- resize ]
add-method

<window> "set-height"
  !( window height -- window )
  [ over <- width swap 2array <-- resize ]
add-method

<window> "set-border-width"
  !( window n -- window )
  [ >r dup <- raw r> XSetWindowBorderWidth drop ]
add-method

! 3.8 Changing Window Stacking Order

<window> "raise"
  !( window -- window )
  [ dup <- raw XRaiseWindow drop ]
add-method

<window> "lower"
  !( window -- window )
  [ dup <- raw XLowerWindow drop ]
add-method

! 3.9 - Changing Window Attributes

! : change-window-attributes ( valuemask attr window -- )
! -rot >r >r <- raw r> r> XChangeWindowAttributes drop ;

<window> "change-attributes" !( window valuemask attr -- window ) [
>r >r dup <- raw r> r> XChangeWindowAttributes drop 
] add-method

DEFER: lookup-color

<window> "set-background"
  !( window color -- window )
  [ >r dup <- raw r> lookup-color XSetWindowBackground drop ]
add-method

<window> "set-gravity" !( window gravity -- window ) [
CWWinGravity swap
"XSetWindowAttributes" <c-object> tuck set-XSetWindowAttributes-win_gravity
<--- change-attributes
] add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4 - Window Information Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 4.1 - Obtaining Window Information

<window> {

"children" !( window -- seq )
  [ <- raw 0 <uint> 0 <uint> f <void*> 0 <uint> 2dup >r >r XQueryTree drop
    r> r> swap *void* swap *uint c-uint-array>
    [ dpy get swap <window> new ] map ]

"parent" !( window -- parent ) [
  dup $dpy >r

  dup $dpy $ptr
  swap $id
  0 <Window>
  0 <Window> dup >r
  f <void*>
  0 <uint>
    XQueryTree drop
  r> *Window
  r> swap
    <window> new
  check-window-table ]

"size" !( window -- size )
  [ <- raw 0 <Window> 0 <int> 0 <int>
    0 <uint> 0 <uint> 2dup 2array >r
    0 <uint> 0 <uint>
    XGetGeometry drop r> [ *uint ] map ]

"width" !( window -- width ) [ <- size first ]

"height" !( window -- height ) [ <- size second ]

"position" !( window -- position )
  [ <- raw 0 <Window>
    0 <uint> 0 <uint> 2dup 2array >r
    0 <uint> 0 <uint> 0 <uint> 0 <uint>
    XGetGeometry drop r> [ *int ] map ]

"x" !( window -- x ) [ <- position first ]

"y" !( window -- y ) [ <- position second ]

"as-rect" !( window -- rect ) [ dup <- position swap <- size <rect> new ]

"attributes" !( window -- XWindowAttributes )
  [ <- raw "XWindowAttributes" <c-object> dup >r XGetWindowAttributes drop r> ]

"map-state" !( window -- state ) [ <- attributes XWindowAttributes-map_state ]

"mapped?" !( window -- ? ) [ <- map-state IsUnmapped = not ]

} add-methods

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: get-atom-name ( atom -- name ) dpy get $ptr swap XGetAtomName ;

: intern-atom ( atom-name only-if-exists? -- atom )
dpy get $ptr -rot XInternAtom ;

: lookup-color ( name -- pixel )
dpy get $ptr dpy get $colormap rot
"XColor" <c-object> dup >r "XColor" <c-object> XLookupColor drop
dpy get $ptr dpy get $colormap r> dup >r XAllocColor drop r> XColor-pixel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<window> "clear"
  !( window -- window )
  [ dup <- raw XClearWindow drop ]
add-method

<window> "draw-string"
  !( window gc pos string -- )
  [ >r >r >r <- raw r> $ptr r> [ >fixnum ] map first2 r> dup length
    XDrawString drop ]
add-method

! <window> "draw-string"
!   !( window gc pos string -- )
!   [ >r >r >r <- raw r> $ptr r> [ >fixnum ] map first2 r> dup length
!     XDrawString drop ]
! add-method

<window> "draw-line"
  !( window gc a b -- )
  [ >r >r >r <- raw r> $ptr r> first2 r> first2 XDrawLine drop ]
add-method

<window> "draw-rect"
  !( window gc rect -- )
  [ 3dup dup <- top-left    swap <- top-right    <---- draw-line
    3dup dup <- top-right   swap <- bottom-right <---- draw-line
    3dup dup <- bottom-left swap <- bottom-right <---- draw-line
    	 dup <- top-left    swap <- bottom-left  <---- draw-line ]
add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 9 - Window and Session Manager Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<window> "reparent"
  !( window parent -- window )
  [ >r dup <- raw r> $id 0 0 XReparentWindow drop ]
add-method

<window> "add-to-save-set" !( window -- window ) [
  dup <- raw XAddToSaveSet drop
] add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 10 - Events
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: XButtonEvent-root-position ( event -- position )
dup XButtonEvent-x_root swap XButtonEvent-y_root 2array ;

: XMotionEvent-root-position ( event -- position )
dup XMotionEvent-x_root swap XMotionEvent-y_root 2array ;

! Utility words for XConfigureRequestEvent

: XConfigureRequestEvent-position ( XConfigureRequestEvent -- position )
dup XConfigureRequestEvent-x swap XConfigureRequestEvent-y 2array ;

: XConfigureRequestEvent-size ( XConfigureRequestEvent -- size )
dup XConfigureRequestEvent-width swap XConfigureRequestEvent-height 2array ;

: bit-test ( a b -- t-or-f ) bitand 0 = not ;

: CWX? ( XConfigureRequestEvent -- bool )
XConfigureRequestEvent-value_mask CWX bit-test ;

: CWY? ( XConfigureRequestEvent -- bool )
XConfigureRequestEvent-value_mask CWY bit-test ;

: CWWidth? ( XConfigureRequestEvent -- bool )
XConfigureRequestEvent-value_mask CWWidth bit-test ;

: CWHeight? ( XConfigureRequestEvent -- bool )
XConfigureRequestEvent-value_mask CWHeight bit-test ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<window> "select-input"
  !( window mask -- window )
  [ >r dup <- raw r> XSelectInput drop ]
add-method

! 11.8 - Handling Protocol Errors

SYMBOL: error-handler-quot

: error-handler-callback ( -- xt )
"void" { "Display*" "XErrorEvent*" } "cdecl"
[ error-handler-quot get call ] alien-callback ; 

: set-error-handler ( quot -- )
error-handler-quot set error-handler-callback XSetErrorHandler drop ;

: install-default-error-handler ( -- )
[ "X11 : error-handler called" print flush ] set-error-handler ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 12.2 - Keyboard Grabbing

: grab-key
( keycode modifiers grab-window owner-events pointer-mode keyboard-mode -- )
>r >r >r <- raw >r -rot r> r> r> r> XGrabKey drop ;

! 12.5 - Controlling Input Focus

<window> "set-input-focus" !( window revert-to time -- window )
  [ >r >r dup <- raw r> r> XSetInputFocus drop ]
add-method

: get-input-focus ( -- window )
  dpy> $ptr
  0 <Window> dup >r
  0 <int>
    XGetInputFocus drop
  r> *Window
    dpy> swap
  create-window-from-id
  check-window-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 14 - Inter-Client Communication Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<window> "fetch-name" !( window -- name-or-f )
  [ <- raw f <void*> dup >r   XFetchName drop   r>
    dup *void* alien-address 0 = [ drop f ] [ *char* ] if ]
add-method

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 16 - Application Utility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 16.1 - Using Keyboard Utility Functions

! this should go in xlib.factor

USING: alien.syntax ;

FUNCTION: KeyCode XKeysymToKeycode ( Display* display, KeySym keysym ) ;

FUNCTION: KeySym XKeycodeToKeysym ( Display* display,
	  	 		    KeyCode keycode,
				    int index ) ;

FUNCTION: char* XKeysymToString ( KeySym keysym ) ;

: keysym-to-keycode ( keysym -- keycode ) dpy get $ptr swap XKeysymToKeycode ;

USE: strings

: lookup-string* ( event -- keysym string )
10 "char" <c-array> dup >r  10  0 <KeySym> dup >r  f  XLookupString
r> *KeySym  swap r> swap c-char-array> >string ;

: lookup-string ( event -- string ) lookup-string* nip ;

: lookup-keysym ( event -- keysym ) lookup-string* drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!7

: event-to-keysym ( event index -- keysym )
>r dup XKeyEvent-display swap XKeyEvent-keycode r> XKeycodeToKeysym ;

: keysym-to-string ( keysym -- string ) XKeysymToString ;

: key-event-to-string ( event index -- str ) event-to-keysym keysym-to-string ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Misc
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: no-modifiers ( -- mask ) 0 ;

: control-alt ( -- mask ) ControlMask Mod1Mask bitor ;

: alt ( -- mask ) Mod1Mask ;

: True  1 ;
: False 0 ;

<window> "send-client-message" !( window message-type data -- window ) [

"XClientMessageEvent" <c-object>

tuck               set-XClientMessageEvent-data0
tuck               set-XClientMessageEvent-message_type
over $id over      set-XClientMessageEvent-window
ClientMessage over set-XClientMessageEvent-type
32            over set-XClientMessageEvent-format
CurrentTime   over set-XClientMessageEvent-data1

>r dup <- raw False NoEventMask r> XSendEvent drop

] add-method