! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types hashtables kernel math math.vectors
namespaces sequences x11.xlib x11.constants x11.glx ;
IN: x11.windows

: create-window-mask ( -- n )
    CWBackPixel CWBorderPixel bitor
    CWColormap bitor CWEventMask bitor ;

: create-colormap ( visinfo -- colormap )
    dpy get root get rot XVisualInfo-visual AllocNone
    XCreateColormap ;

: event-mask ( -- n )
    ExposureMask
    StructureNotifyMask bitor
    KeyPressMask bitor
    KeyReleaseMask bitor
    ButtonPressMask	bitor
    ButtonReleaseMask bitor
    PointerMotionMask bitor
    FocusChangeMask bitor
    EnterWindowMask bitor
    LeaveWindowMask bitor
    PropertyChangeMask bitor ;

: window-attributes ( visinfo -- attributes )
    "XSetWindowAttributes" <c-object>
    0 over set-XSetWindowAttributes-background_pixel
    0 over set-XSetWindowAttributes-border_pixel
    [ >r create-colormap r> set-XSetWindowAttributes-colormap ] keep
    event-mask over set-XSetWindowAttributes-event_mask ;

: set-size-hints ( window -- )
    "XSizeHints" <c-object>
    USPosition over set-XSizeHints-flags
    dpy get -rot XSetWMNormalHints ;

: auto-position ( window loc -- )
    { 0 0 } = [ drop ] [ set-size-hints ] if ;

: create-window ( loc dim visinfo -- window )
    pick >r
    >r >r >r dpy get root get r> first2 r> { 1 1 } vmax first2 0 r>
    [ XVisualInfo-depth InputOutput ] keep
    [ XVisualInfo-visual create-window-mask ] keep
    window-attributes XCreateWindow
    dup r> auto-position ;

: glx-window ( loc dim -- window glx )
    choose-visual
    [ create-window ] keep
    [ create-glx ] keep
    XFree ;

: destroy-window ( win -- )
    dpy get swap XDestroyWindow drop ;

: set-closable ( win -- )
    dpy get swap "WM_DELETE_WINDOW" x-atom <Atom> 1
    XSetWMProtocols drop ;

: map-window ( win -- ) dpy get swap XMapWindow drop ;

: unmap-window ( win -- ) dpy get swap XUnmapWindow drop ;
