
IN: x USING: namespaces kernel sequences xlib ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root
SYMBOL: gcontext
SYMBOL: win
SYMBOL: black-pixel
SYMBOL: white-pixel

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.3 - Creating Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! create-window is radically simple. It takes no arguments but you get
! a window back! After you create-window you should modify it's
! properties to liking, then do the flush. This way is opposed to
! calling a create window function with all the properties as
! arguments.

: create-window ( -- win )
dpy get root get 0 0 100 100 10 black-pixel get white-pixel get
XCreateSimpleWindow ;

: destroy-window ( -- ) dpy get win get XDestroyWindow drop ;

: map-window ( -- ) dpy get win get XMapWindow drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 3.7 - Configuring Windows
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-window ( { x y } -- ) >r dpy get win get r> [ ] each XMoveWindow drop ;

: resize-window ( { width height } -- )
>r dpy get win get r> [ ] each XResizeWindow drop ;

! 3.8 Changing Window Stacking Order

: raise-window ( -- ) dpy get win get XRaiseWindow drop ;
: lower-window ( -- ) dpy get win get XLowerWindow drop ;

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

: reparent-window ( parent -- ) >r dpy get win get r> 0 0 XReparentWindow ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: select-input ( mask -- ) >r dpy get win get r> XSelectInput drop ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: next-event ( -- event ) dpy get <XEvent> dup XNextEvent drop ;

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
  dpy get scr get XDefaultGC gcontext set ;