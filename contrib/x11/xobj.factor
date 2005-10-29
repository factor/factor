
IN: xobj
USING: kernel namespaces lists sequences xlib ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

TUPLE: window display id ;

: raw-window ( <window> -- display id )
dup window-display swap window-id ;

: open-display ( string-or-f -- )
XOpenDisplay dpy set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.3 - Creating Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : create-window* ( -- <window> )
! dpy get root get 0 0 100 100 10 "black" get "white" get XCreateSimpleWindow
! dpy get swap <window> ;

: create-window ( dpy parent -- <window> )
swap dup rot
0 0 100 100 10 "black" get "white" get XCreateSimpleWindow
<window> ;

: create-window* ( -- win )
dpy get root get 0 0 100 100 10 "black" get "white" get XCreateSimpleWindow ;

: destroy-window ( <window> -- )
raw-window XDestroyWindow drop ;

: map-window ( <window> -- )
raw-window XMapWindow drop ;

: map-window* ( -- )
dpy get win get XMapWindow drop ;

: map-subwindows ( <window> -- )
raw-window XMapSubwindows drop ;

: unmap-window ( <window> -- )
raw-window XUnmapWindow drop ;

: flush-window ( <window> -- )
window-display XFlush drop ;

: flush-dpy ( -- )
dpy get XFlush drop ;

: reparent ( window parent -- )
swap raw-window rot window-id 0 0 XReparentWindow ;

: lookup-color ( name -- pixel ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.7 - Configuring Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-window ( <window> x y -- )
>r >r raw-window r> r> XMoveWindow drop ;

: resize-window ( <window> width height -- )
>r >r raw-window r> r> XResizeWindow drop ;

: resize-window* ( width height -- )
>r >r dpy get win get r> r> XResizeWindow drop ;

: set-border-width ( <window> width -- )
swap raw-window rot XSetWindowBorderWidth drop ;

! 3.8 Changing Window Stacking Order

: raise-window ( <window> -- ) raw-window XRaiseWindow drop ;
: lower-window ( <window> -- ) raw-window XLowerWindow drop ;

! 3.9 - Changing Window Attributes

: sattr-background-pixel ( val -- sattr )
<XSetWindowAttributes> dup -rot set-XSetWindowAttributes-background_pixel ;

: set-window-background-pixel ( <window> pixel -- )
swap raw-window rot CWBackPixel swap sattr-background-pixel
XChangeWindowAttributes drop ;

! 4 - Window Information Functions

: XGetWindowAttributes* ( <window> -- attr )
raw-window <XWindowAttributes> dup >r XGetWindowAttributes drop r> ;

: window-x XGetWindowAttributes* XWindowAttributes-x ;
: window-y XGetWindowAttributes* XWindowAttributes-y ;
: window-width XGetWindowAttributes* XWindowAttributes-width ;
: window-height XGetWindowAttributes* XWindowAttributes-height ;

! 8 - Graphics Functions

SYMBOL: win
SYMBOL: gcontext

: clear-window ( <window> -- )
raw-window XClearWindow ;

: clear-window* ( -- )
dpy get win get XClearWindow drop ;


: draw-point ( <window> gc x y -- )
>r >r >r raw-window r> r> r> XDrawPoint drop ;

: draw-point* ( { x y } -- )
>r dpy get win get gcontext get r> [ ] each XDrawPoint drop ;

: draw-line ( <window> gc x1 y1 x2 y2 -- )
>r >r >r >r >r raw-window r> r> r> r> r> XDrawLine drop ;

! 8.6 - Drawing Text

: draw-string ( <window> gc x y string -- )
>r >r >r >r raw-window r> r> r> r> dup length XDrawString drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 9 - Window and Session Manager Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reparent-window ( window parent -- )
>r raw-window r> window-id 0 0 XReparentWindow drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: select-input ( <window> mask -- )
>r raw-window r> XSelectInput drop ;

: flush-window ( <window> -- )
window-display XFlush drop ;

! : next-event ( dpy -- event )
! <XEvent> dup >r XNextEvent drop r> ;

: next-event ( -- event )
dpy get <XEvent> dup >r XNextEvent drop r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Not Categorized Yet
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-window ( window quot -- ) [ swap window set call ] with-scope ; inline

: initialize-x ( display-string -- )
  XOpenDisplay dpy set
  dpy get XDefaultScreen scr set
  dpy get scr get XRootWindow root set
  dpy get scr get XBlackPixel "black" set
  dpy get scr get XWhitePixel "white" set
  dpy get scr get XDefaultGC gcontext set ;