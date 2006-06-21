USING: namespaces kernel compiler math arrays strings alien sequences io
prettyprint x11 rectangle ;

IN: x 

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root
SYMBOL: gcontext
SYMBOL: win
SYMBOL: black-pixel
SYMBOL: white-pixel
SYMBOL: colormap

SYMBOL: font

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <ulong> <uint> ;
: <XID> <ulong> ;
: <Window> <XID> ;
: <Drawable> <XID> ;

: *ulong *uint ;
: *XID *ulong ;
: *Window *XID ;
: *Drawable *XID ;

: True 1 ;
: False 0 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3 - Window Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 3.3 - Creating Windows

! create-window is radically simple. It takes no arguments but you get
! a window back! After you create-window you should modify it's
! properties to liking, then do the flush. This way is opposed to
! calling a create window function with all the properties as
! arguments.

: create-window ( -- win )
  dpy get root get 0 0 100 100 0 black-pixel get white-pixel get
  XCreateSimpleWindow ;

: destroy-window ( -- ) dpy get win get XDestroyWindow drop ;

: map-window ( -- ) dpy get win get XMapWindow drop ;

: map-subwindows ( -- ) dpy get win get XMapSubwindows drop ;

: unmap-window ( -- ) dpy get win get XUnmapWindow drop ;

: unmap-subwindows ( -- ) dpy get win get XUnmapSubwindows drop ;

! 3.7 - Configuring Windows

: move-window ( { x y } -- ) >r dpy get win get r> [ ] each XMoveWindow drop ;

DEFER: window-position
DEFER: window-width
DEFER: window-height
DEFER: window-parent
DEFER: with-win

: set-window-x ( x -- ) 0 window-position dup >r set-nth r> move-window ;

: set-window-y ( y -- ) 1 window-position dup >r set-nth r> move-window ;

: set-window-center-x ( x -- ) window-width 2 / - set-window-x ;

: center-window-horizontally
  window-parent [ window-width ] with-win
  2 / set-window-center-x ;

: resize-window ( { width height } -- )
  >r dpy get win get r> [ ] each XResizeWindow drop ;

: set-window-width ( width -- )
  window-height 2array resize-window ;

: set-window-height ( height -- )
  window-width swap 2array resize-window ;

: set-window-border-width ( width -- )
  >r dpy get win get r> XSetWindowBorderWidth drop ;

! 3.8 Changing Window Stacking Order

: raise-window ( -- ) dpy get win get XRaiseWindow drop ;
: lower-window ( -- ) dpy get win get XLowerWindow drop ;

! 3.9 - Changing Window Attributes

: change-window-attributes ( valuemask attr -- )
>r >r dpy get win get r> r> XChangeWindowAttributes drop ;

: set-window-background ( pixel -- )
  >r dpy get win get r> XSetWindowBackground drop ;

: set-window-gravity ( gravity -- )
CWWinGravity swap
"XSetWindowAttributes" <c-object> tuck
set-XSetWindowAttributes-win_gravity
change-window-attributes ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4 - Window Information Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 4.1 - Obtaining Window Information

: window-children ( -- [ child child ... child ] )
  dpy get win get 0 <uint> 0 <uint>
  0 <uint> <void*>   0 <uint>   2dup >r >r
  XQueryTree drop
  r> r>					! children-return nchildren-return
  swap *void* swap *uint		! children nchildren
  [ over uint-nth ] map
  swap drop ;

: window-parent ( -- parent )
  dpy get win get 0 <Window> 0 <Window> dup >r 0 <uint> <void*> 0 <uint>
  XQueryTree drop
  r> *Window ;

: window-size ( -- { width height } )
  dpy get win get 0 <Window> 0 <int> 0 <int>
  0 <uint> 0 <uint> 2dup 2array >r
  0 <uint> 0 <uint>
  XGetGeometry drop r> [ *uint ] map ;

: window-width 0 window-size nth ;

: window-height 1 window-size nth ;

: window-position ( -- { x y } )
  dpy get win get 0 <Window>
  0 <int> 0 <int> 2dup 2array >r
  0 <uint> 0 <uint> 0 <uint> 0 <uint>
  XGetGeometry drop r> [ *int ] map ;

: window-x 0 window-position nth ;
: window-y 1 window-position nth ;

: get-window-attributes ( -- <XWindowAttributes> )
  dpy get win get "XWindowAttributes" <c-object> dup >r XGetWindowAttributes drop r> ;

: window-root get-window-attributes XWindowAttributes-root ;

: window-map-state
  get-window-attributes XWindowAttributes-map_state ;

: window-event-mask
get-window-attributes XWindowAttributes-your_event_mask ;

: window-all-event-masks
get-window-attributes XWindowAttributes-all_event_masks ;

: window-override-redirect
  get-window-attributes XWindowAttributes-override_redirect ;

! 4.3 - Properties and Atoms

: intern-atom ( atom-name only-if-exists? -- atom )
>r >r dpy get r> r> XInternAtom ;

: get-atom-name ( atom -- name ) dpy get swap XGetAtomName ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: event-masks

{ { "NoEventMask" 0 }
  { "KeyPressMask" 1 }
  { "KeyReleaseMask" 2 }
  { "ButtonPressMask" 4 }
  { "ButtonReleaseMask" 8 }
  { "EnterWindowMask" 16 }
  { "LeaveWindowMask" 32 }
  { "PointerMotionMask" 64 }
  { "PointerMotionHintMask" 128 }
  { "Button1MotionMask" 256 }
  { "Button2MotionMask" 512 }
  { "Button3MotionMask" 1024 }
  { "Button4MotionMask" 2048 }
  { "Button5MotionMask" 4096 }
  { "ButtonMotionMask" 8192 }
  { "KeymapStateMask" 16384 }
  { "ExposureMask" 32768 }
  { "VisibilityChangeMask" 65536 }
  { "StructureNotifyMask" 131072 }
  { "ResizeRedirectMask" 262144 }
  { "SubstructureNotifyMask" 524288 }
  { "SubstructureRedirectMask" 1048576 }
  { "FocusChangeMask" 2097152 }
  { "PropertyChangeMask" 4194304 }
  { "ColormapChangeMask" 8388608 }
  { "OwnerGrabButtonMask" 16777216 }
} event-masks set-global

: bit-test ( a b -- t-or-f ) bitand 0 = not ;
  
: name>event-mask ( str -- i )
event-masks get [ first over = ] find 2nip second ;

: event-mask>name ( i -- str )
event-masks get [ second over = ] find 2nip first ;

: event-mask-names ( -- seq ) event-masks get [ first ] map ;

: event-mask>names ( mask -- seq )
event-mask-names [ name>event-mask bit-test ] subset-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Pretty printing window information
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: print-field ( name value -- ) swap "=" append write pprint ;

: spc ( -- ) " " write ;

: print-window-geometry ( -- )
window-width pprint "x" write window-height pprint "+" write
window-x pprint "+" write window-y pprint ;

: print-map-state ( -- )
"map-state=" write
window-map-state
{ { [ dup 0 = ] [ drop "IsUnmapped" write ] }
  { [ dup 1 = ] [ drop "IsUnviewable" write ] }
  { [ dup 2 = ] [ drop "IsViewable" write ] }
} cond ;

: print-window-info ( -- )
"id" win get print-field spc
"parent" window-parent print-field spc
"root" window-root print-field spc
print-window-geometry terpri
"children" window-children print-field terpri
"override-redirect" window-override-redirect print-field spc
print-map-state terpri
"event-mask" window-event-mask event-mask>names print-field terpri
"all-event-masks" window-all-event-masks event-mask>names print-field
terpri ;

: .win print-window-info ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 6 - Color Management Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lookup-color ( name -- pixel )
  >r dpy get colormap get r> "XColor" <c-object> dup >r "XColor" <c-object> XLookupColor drop
  dpy get colormap get r> dup >r XAllocColor drop
  r> XColor-pixel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 7 - Graphics Context Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: create-gc ( -- GC ) dpy get win get 0 0 <alien> XCreateGC ;

: set-foreground ( foreground -- )
dpy get gcontext get rot XSetForeground drop ;

: set-background ( background -- )
dpy get gcontext get rot XSetBackground drop ;

: set-function ( function -- ) dpy get gcontext get rot XSetFunction drop ;

: set-subwindow-mode ( subwindow-mode -- )
dpy get gcontext get rot XSetSubwindowMode drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: clear-window ( -- ) dpy get win get XClearWindow drop ;

: draw-point ( { x y } -- )
  >r dpy get win get gcontext get r> [ ] each XDrawPoint drop ;

: draw-line ( { x1 y1 } { x2 y2 } -- )
  >r >r dpy get win get gcontext get r> [ ] each r> [ ] each XDrawLine drop ;

: 2nth ( i seq -- item-i item-i+1 ) 2dup nth -rot swap 1 + swap nth ;

: draw-lines ( seq -- )
dup length 1 - [ swap 2nth draw-line ] each-with ;

: 4array 3array swap 1array swap append ;

: 5array 4array swap 1array swap append ;

: draw-rect ( rect -- )
[ top-left ] keep [ top-right ] keep [ bottom-right ] keep
[ bottom-left ] keep top-left 5array draw-lines ;

: draw-rect+ [ draw-rect ] with-win ;

! 8.5 - Font Metrics

: load-query-font ( name -- <XFontStruct> ) dpy get swap XLoadQueryFont ;

! : text-width ( <XFontStruct> string -- width ) dup length XTextWidth ;

! : text-width ( string -- width ) font get swap dup length XTextWidth ;

: font-height ( <XFontStruct> -- height )
  dup XFontStruct-ascent swap XFontStruct-descent + ;

! 8.6 - Drawing Text

: draw-string ( { x y } string -- ) >r >r
dpy get win get gcontext get r> [ ] each r> dup length XDrawString drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 9 - Window and Session Manager Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reparent-window ( parent -- ) >r
dpy get win get r> 0 0 XReparentWindow drop ;

: add-to-save-set ( -- ) dpy get win get XAddToSaveSet drop ;

: grab-server ( -- ) dpy get XGrabServer drop ;

: ungrab-server ( -- ) dpy get XUngrabServer drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: select-input ( mask -- ) >r dpy get win get r> XSelectInput drop ;

: add-input ( mask -- )
window-event-mask bitor dpy get win get rot XSelectInput drop ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: sync-dpy ( discard -- ) >r dpy get r> XSync ;

: next-event ( -- event )
dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
  >r dpy get r> "XEvent" <c-object> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

! 11.8 - Handling Protocol Errors

SYMBOL: error-handler-quot

: error-handler-callback ( -- xt ) "void" { "Display*" "XErrorEvent*" }
[ error-handler-quot get call ] alien-callback ; compiled

: set-error-handler ( quot -- )
error-handler-quot set error-handler-callback XSetErrorHandler drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-input-focus ( revert-to time -- )
  >r >r dpy get win get r> r> XSetInputFocus drop ;

: grab-pointer ( mask -- )
>r dpy get win get 0 r> GrabModeAsync GrabModeAsync None None CurrentTime
XGrabPointer drop ;

: ungrab-pointer ( time -- )
  >r dpy get r> XUngrabPointer drop ;

: grab-key ( keycode modifiers owner-events pointer-mode keyboard-mode -- )
>r >r >r >r >r dpy get r> r> win get r> r> r> XGrabKey drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 14 - Inter-Client Communication Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fetch-name ( -- name-or-f )
  dpy get win get 0 <int> <void*> dup >r XFetchName drop r>
  dup *void* alien-address 0 = [ drop f ] [ *char* ] if ;

: get-transient-for-hint ( -- win-or-f )
  dpy get win get 0 <Window> dup >r XGetTransientForHint r>
  swap 0 = [ drop f ] [ *Window ] if ;

! 14.1.10.  Setting and Reading the WM_PROTOCOLS Property

: <Atom**> ( value -- address ) <Atom> <void*> ;

: get-wm-protocols ( -- protocols )
dpy get win get 0 <Atom**> 0 <int> 2dup >r >r XGetWMProtocols drop
r> r>				! protocols-return count-return
swap *void* swap *int		! protocols count
[ over int-nth ] map
nip ;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Not Categorized Yet
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: window-width+			[ window-width ] with-win ;
: window-height+		[ window-height ] with-win ;
: move-window+			[ move-window ] with-win ;
: resize-window+		[ resize-window ] with-win ;
: set-window-y+			[ set-window-y ] with-win ;
: set-window-width+		[ set-window-width ] with-win ;
: set-window-height+		[ set-window-height ] with-win ;
: center-window-horizontally+ 	[ center-window-horizontally ] with-win ;
: window-children+		[ window-children ] with-win ;
: window-map-state+		[ window-map-state ] with-win ;
: destroy-window+		[ destroy-window ] with-win ;
: map-window+			[ map-window ] with-win ;
: unmap-window+			[ unmap-window ] with-win ;
: window-parent+		[ window-parent ] with-win ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-dpy ( dpy quot -- ) [ swap dpy set call ] with-scope ; inline
: with-win ( win quot -- ) [ swap win set call ] with-scope ; inline

: with-gcontext ( gcontext quot -- )
[ swap gcontext set call ] with-scope ; inline

: initialize-x ( display-string -- )
  XOpenDisplay dpy set
  dpy get XDefaultScreen scr set
  dpy get scr get XRootWindow root set
  dpy get scr get XBlackPixel black-pixel set
  dpy get scr get XWhitePixel white-pixel set
  dpy get scr get XDefaultGC gcontext set
  dpy get scr get XDefaultColormap colormap set
  "6x13" load-query-font font set
  dpy get gcontext get font get XFontStruct-fid XSetFont drop ;

: stack-children ( -- )
  window-children
  [ [ { 0 0 } move-window ] with-win ]
  each ;

: arrange-children-horizontally ( -- )
  0
  window-children
  [ [ dup set-window-x window-width + ] with-win ]
  each ;

: arrange-children-vertically ( -- )
  0
  window-children
  [ [ dup set-window-y window-height + ] with-win ]
  each ;

: vertical-layout ( space -- )
  dup						! space y
  window-children
						! space y child
  [ 2dup					! space y child y child
    set-window-y+				! space y child
    window-height+				! space y height
    +						! space new-y
    dupd					! space space new-y
    + ]						! space new-y
  each
  drop drop ;

: valid-window? ( -- ? )
dpy get win get "XWindowAttributes" <c-object> XGetWindowAttributes 0 = not ;

: valid-window?+		[ valid-window? ] with-win ;

: mouse-sensor ( -- { root-x root-y } )
  dpy get win get 0 <Window> 0 <Window> 0 <int> 0 <int> 2dup >r >r
  0 <int> 0 <int> 0 <uint> XQueryPointer drop r> *int r> *int 2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Windows and their children
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: seq-max ( v -- item ) dup 0 swap nth [ max ] reduce ;

: seq-last ( v -- item ) dup length 1 - swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: widest-child-width ( window -- width )
  window-children+ [ window-width+ ] map seq-max ;

: tallest-child-height ( window -- height )
  window-children+ [ window-height+ ] map seq-max ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: compare-window-width ( w w -- -1/0/1 )
  window-width+ swap window-width+ swap < ;

: sort-by-width ( window-seq -- seq ) [ compare-window-width ] sort ;

: widest-child ( window -- child ) window-children+ sort-by-width seq-last ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: compare-window-height ( w w -- -1/0/1 )
  window-height+ swap window-height+ swap < ;

: sort-by-height ( window-seq -- seq ) [ compare-window-height ] sort ;

: tallest-child ( window -- child ) window-children+ sort-by-height seq-last ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: char-array>string ( n <char-array> -- string )
swap >array [ swap char-nth ] map-with >string ;

: lookup-string ( event -- string )
10 "char" <c-array> dup >r 10 0 <alien> 0 <alien> XLookupString r>
char-array>string ;

: send-client-message ( atom x -- )

"XClientMessageEvent" <c-object>			! atom x event

ClientMessage over set-XClientMessageEvent-type
win get over set-XClientMessageEvent-window
rot over set-XClientMessageEvent-message_type		! x event
32 over set-XClientMessageEvent-format
swap over set-XClientMessageEvent-data0			! event
CurrentTime over set-XClientMessageEvent-data1		! event

>r dpy get win get False NoEventMask r> XSendEvent drop ;