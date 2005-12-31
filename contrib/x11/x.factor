
IN: x USING: namespaces kernel math arrays strings alien sequences xlib ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.3 - Creating Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

: set-window-background ( pixel -- )
  >r dpy get win get r> XSetWindowBackground drop ;

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
  dpy get win get <XWindowAttributes> dup >r XGetWindowAttributes drop r> ;

: window-map-state
  get-window-attributes XWindowAttributes-map_state ;

: window-override-redirect
  get-window-attributes XWindowAttributes-override_redirect ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 6 - Color Management Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: lookup-color ( name -- pixel )
  >r dpy get colormap get r> <XColor> dup >r <XColor> XLookupColor drop
  dpy get colormap get r> dup >r XAllocColor drop
  r> XColor-pixel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: clear-window ( -- ) dpy get win get XClearWindow drop ;

: draw-point ( { x y } -- )
  >r dpy get win get gcontext get r> [ ] each XDrawPoint drop ;

: draw-line ( { x1 y1 } { x2 y2 } -- )
  >r >r dpy get win get gcontext get r> [ ] each r> [ ] each XDrawLine drop ;

! 8.5 - Font Metrics

: load-query-font ( name -- <XFontStruct> ) dpy get swap XLoadQueryFont ;

! : text-width ( <XFontStruct> string -- width ) dup length XTextWidth ;

! : text-width ( string -- width ) font get swap dup length XTextWidth ;

: font-height ( <XFontStruct> -- height )
  dup XFontStruct-ascent swap XFontStruct-descent + ;

! 8.6 - Drawing Text

: draw-string ( { x y } string -- )
  >r >r dpy get win get gcontext get r> [ ] each r> dup length XDrawString drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 9 - Window and Session Manager Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reparent-window ( parent -- ) >r dpy get win get r> 0 0 XReparentWindow drop ;

: add-to-save-set ( -- ) dpy get win get XAddToSaveSet drop ;

: grab-server ( -- ) dpy get XGrabServer drop ;

: ungrab-server ( -- ) dpy get XUngrabServer drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: select-input ( mask -- ) >r dpy get win get r> XSelectInput drop ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: sync-dpy ( discard -- ) >r dpy get r> XSync ;

: next-event ( -- event ) dpy get <XEvent> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
  >r dpy get r> <XEvent> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-input-focus ( revert-to time -- )
  >r >r dpy get win get r> r> XSetInputFocus drop ;

: grab-pointer ( mask -- )
  >r dpy get win get False r> GrabModeAsync GrabModeAsync None None CurrentTime
  XGrabPointer drop ;

: ungrab-pointer ( time -- )
  >r dpy get r> XUngrabPointer drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 14 - Inter-Client Communication Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fetch-name ( -- name-or-f )
  dpy get win get 0 <int> <void*> dup >r XFetchName drop r>
  dup *void* alien-address 0 = [ drop f ] [ *char* ] if ;

: get-transient-for-hint ( -- win-or-f )
  dpy get win get 0 <Window> dup >r XGetTransientForHint r>
  swap 0 = [ drop f ] [ *Window ] if ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-dpy ( dpy quot -- ) [ swap dpy set call ] with-scope ; inline
: with-win ( win quot -- ) [ swap win set call ] with-scope ; inline

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
  dpy get win get <XWindowAttributes> XGetWindowAttributes 0 = not ;

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
10 <char-array> dup >r 10 0 <alien> 0 <alien> XLookupString r>
char-array>string ;