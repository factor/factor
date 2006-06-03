! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien gadgets hashtables kernel math namespaces sequences ;

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
    LeaveWindowMask bitor ;

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

: create-window ( loc dim visinfo -- window )
    >r >r >r dpy get root get r> first2 r> first2 0 r>
    [ XVisualInfo-depth InputOutput ] keep
    [ XVisualInfo-visual create-window-mask ] keep
    window-attributes XCreateWindow
    dup set-size-hints ;

: glx-window ( loc dim -- window context )
    choose-visual
    [ create-window ] keep [ create-context ] keep
    XFree ;

: destroy-window ( win -- )
    dpy get swap XDestroyWindow drop ;

: destroy-window* ( win context -- )
    destroy-context dup unregister-window destroy-window ;

: set-closable ( win -- )
    dpy get swap "WM_DELETE_WINDOW" x-atom <Atom> 1
    XSetWMProtocols drop ;

: map-window ( win -- ) dpy get swap XMapWindow drop ;

: map-window* ( world win -- ) dup set-closable map-window ;

: unmap-window ( win -- ) dpy get swap XUnmapWindow drop ;
