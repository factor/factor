! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors io kernel math namespaces prettyprint
sequences threads ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

! Window management
: create-window-mask ( -- n )
    CWBackPixel CWBorderPixel bitor
    CWColormap bitor CWEventMask bitor ;

: create-colormap ( visinfo -- colormap )
    dpy get root get rot XVisualInfo-visual AllocNone
    XCreateColormap ;

: window-attributes ( visinfo -- attributes )
    "XSetWindowAttributes" <c-object>
    0 over set-XSetWindowAttributes-background_pixel
    0 over set-XSetWindowAttributes-border_pixel
    [ >r create-colormap r> set-XSetWindowAttributes-colormap ] keep
    StructureNotifyMask ExposureMask bitor over set-XSetWindowAttributes-event_mask ;

: create-window ( w h visinfo -- window )
    >r >r >r dpy get root get 0 0 r> r> 0 r>
    [ XVisualInfo-depth InputOutput ] keep
    [ XVisualInfo-visual create-window-mask ] keep
    window-attributes XCreateWindow ;

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

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: wait-event ( -- event )
      QueuedAfterFlush events-queued 0 >
      [ next-event ] [ 10 sleep wait-event ] if ;

: handle-event ( event -- )
    XAnyEvent-type . flush ;

: event-loop ( -- )
    wait-event handle-event event-loop ;

! GLX

: >int-array ( seq -- <int-array> )
    dup length dup "int" <c-array> -rot
    [ pick set-int-nth ] 2each ;

: choose-visual ( -- XVisualInfo* )
    dpy get scr get
    GLX_RGBA GLX_DOUBLEBUFFER 0 3array >int-array
    glXChooseVisual
    [ "Could not get a double-buffered GLX RGBA visual" throw ] unless* ;

: create-context ( XVisualInfo* -- GLXContext )
    >r dpy get r> f 1 glXCreateContext
    [ "Failed to create GLX context" throw ] unless* ;

: make-current ( win GLXContext -- )
    >r dpy get swap r> glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

: swap-buffers ( win -- )
    dpy get swap glXSwapBuffers ;

! Initialization

: check-display
    [ "Cannot connect to X server - check $DISPLAY" throw ] unless* ;

: (initialize-x) ( display-string -- )
    XOpenDisplay check-display dpy set
    dpy get XDefaultScreen scr set
    dpy get scr get XRootWindow root set ;

: initialize-x ( display-string -- )
    dpy get [
        drop
    ] [
        (initialize-x) [ event-loop ] in-thread
    ] if ;
