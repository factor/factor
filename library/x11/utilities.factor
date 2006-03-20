! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors kernel namespaces sequences ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root
SYMBOL: black-pixel
SYMBOL: white-pixel

! Initialization

: initialize-x ( display-string -- )
    XOpenDisplay [ "Cannot connect to X server" throw ] unless*
    dpy set
    dpy get XDefaultScreen scr set
    dpy get scr get XRootWindow root set
    dpy get scr get XBlackPixel black-pixel set
    dpy get scr get XWhitePixel white-pixel set ;

! Window management

: create-window ( dim -- win )
    >r dpy get root get 0 0 r> first2
    0 black-pixel get white-pixel get
    XCreateSimpleWindow ;

: destroy-window ( win -- )
    dpy get swap XDestroyWindow drop ;

: map-window ( win -- )
    dpy get swap XMapWindow drop ;

: map-subwindows ( win -- )
    dpy get swap XMapSubwindows drop ;

: unmap-window ( win -- )
    dpy get swap XUnmapWindow drop ;

: unmap-subwindows ( win -- )
    dpy get swap XUnmapSubwindows drop ;

! Event handling

: select-input ( win mask -- )
    >r dpy get swap r> XSelectInput drop ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: sync-dpy ( discard -- ) >r dpy get r> XSync ;

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
  >r dpy get r> "XEvent" <c-object> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

! GLX

: >int-array ( seq -- <int-array> )
    [ length "int" <c-array> ] keep dup length
    [ pick set-int-nth ] 2each ;

: choose-visual ( -- XVisualInfo* )
    dpy get scr get
    GLX_RGBA GLX_DOUBLEBUFFER 0 3array >int-array
    glXChooseVisual ;

: create-context ( XVisualInfo* -- GLXContext )
    >r dpy get r> f 1 glXCreateContext ;

: make-current ( win GLXContext -- )
    >r dpy get swap r> glXMakeCurrent drop ;

: swap-buffers ( win -- )
    dpy get swap glXSwapBuffers ;
