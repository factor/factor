! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien hashtables kernel math namespaces sequences ;

: create-window-mask ( -- n )
    CWBackPixel CWBorderPixel bitor
    CWColormap bitor CWEventMask bitor ;

: create-colormap ( visinfo -- colormap )
    dpy get root get rot XVisualInfo-visual AllocNone
    XCreateColormap ;

: event-mask ( -- n )
    StructureNotifyMask
    KeyPressMask bitor
    KeyReleaseMask bitor
    ButtonPressMask	bitor
    ButtonReleaseMask bitor
    PointerMotionMask bitor ;

: window-attributes ( visinfo -- attributes )
    "XSetWindowAttributes" <c-object>
    0 over set-XSetWindowAttributes-background_pixel
    0 over set-XSetWindowAttributes-border_pixel
    [ >r create-colormap r> set-XSetWindowAttributes-colormap ] keep
    event-mask over set-XSetWindowAttributes-event_mask ;

: create-window ( w h visinfo -- window )
    >r >r >r dpy get root get 0 0 r> r> 0 r>
    [ XVisualInfo-depth InputOutput ] keep
    [ XVisualInfo-visual create-window-mask ] keep
    window-attributes XCreateWindow ;
    
: glx-window ( dim -- window context )
    first2 choose-visual [ create-window ] keep create-context ;

: destroy-window ( win -- )
    dpy get swap XDestroyWindow drop ;

: destroy-window* ( win -- )
    dup windows get remove-hash destroy-window ;

: map-window ( win -- ) dpy get swap XMapWindow drop ;

: map-window* ( world win -- )
    [ windows get set-hash ] keep map-window ;

: glx-window* ( world dim -- win context )
    glx-window >r [ map-window* ] keep r> ;

: unmap-window ( win -- ) dpy get swap XUnmapWindow drop ;

: set-title ( string win -- ) dpy get -rot swap XStoreName drop ;
