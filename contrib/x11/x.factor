
IN: x USING: namespaces kernel math vectors alien sequences xlib ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root
SYMBOL: gcontext
SYMBOL: win
SYMBOL: black-pixel
SYMBOL: white-pixel
SYMBOL: colormap

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <ulong> <uint> ;
: <XID> <ulong> ;
: <Window> <XID> ;
: <Drawable> <XID> ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.7 - Configuring Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-window ( { x y } -- ) >r dpy get win get r> [ ] each XMoveWindow drop ;

: set-window-x ( x -- ) 0 window-position dup >r set-nth r> move-window ;

: set-window-y ( y -- ) 1 window-position dup >r set-nth r> move-window ;

: resize-window ( { width height } -- )
  >r dpy get win get r> [ ] each XResizeWindow drop ;

! 3.8 Changing Window Stacking Order

: raise-window ( -- ) dpy get win get XRaiseWindow drop ;
: lower-window ( -- ) dpy get win get XLowerWindow drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4 - Window Information Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: window-size ( -- { width height } )
  dpy get win get 0 <Window> 0 <int> 0 <int>
  0 <uint> 0 <uint> 2dup 2vector >r
  0 <uint> 0 <uint>
  XGetGeometry drop r> [ *uint ] map ;

: window-width 0 window-size nth ;

: window-height 1 window-size nth ;

: window-position ( -- { x y } )
  dpy get win get 0 <Window>
  0 <int> 0 <int> 2dup 2vector >r
  0 <uint> 0 <uint> 0 <uint> 0 <uint>
  XGetGeometry drop r> [ *int ] map ;

: window-x 0 window-position nth ;
: window-y 1 window-position nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: clear-window ( -- ) dpy get win get XClearWindow drop ;

: draw-point ( { x y } -- )
  >r dpy get win get gcontext get r> [ ] each XDrawPoint drop ;

: draw-line ( { x1 y1 } { x2 y2 } -- )
  >r >r dpy get win get gcontext get r> [ ] each r> [ ] each XDrawLine drop ;

! 8.6 - Drawing Text

: draw-string ( { x y } string -- )
  >r >r dpy get win get gcontext get r> [ ] each r> dup length XDrawString drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 9 - Window and Session Manager Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reparent-window ( parent -- ) >r dpy get win get r> 0 0 XReparentWindow drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: select-input ( mask -- ) >r dpy get win get r> XSelectInput drop ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: next-event ( -- event ) dpy get <XEvent> dup >r XNextEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Not Categorized Yet
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
  dpy get scr get XDefaultColormap colormap set ;

: set-window-background ( pixel -- )
  >r dpy get win get r> XSetWindowBackground drop ;

: lookup-color ( name -- pixel )
  >r dpy get colormap get r> <XColor> dup >r <XColor> XLookupColor drop
  dpy get colormap get r> dup >r XAllocColor drop
  r> XColor-pixel ;

: window-children ( -- [ child child ... child ] )
  dpy get win get 0 <uint> 0 <uint>
  0 <uint> <void*>   0 <uint>   2dup >r >r
  XQueryTree drop
  r> r>					! children-return nchildren-return
  swap *void* swap *uint		! children nchildren
  [ over uint-nth ] map
  swap drop ;

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

