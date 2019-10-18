! Copyright (C) 2005, 2006 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors kernel namespaces sequences ;

: choose-visual ( -- XVisualInfo* )
    dpy get scr get
    [
        GLX_RGBA ,
        GLX_DOUBLEBUFFER ,
        GLX_DEPTH_SIZE , 16 ,
        0 ,
    ] { } make >int-array
    glXChooseVisual
    [ "Could not get a double-buffered GLX RGBA visual" throw ] unless* ;

: create-glx ( XVisualInfo* -- GLXContext )
    >r dpy get r> f 1 glXCreateContext
    [ "Failed to create GLX context" throw ] unless* ;
    
: destroy-glx ( GLXContext -- )
    dpy get swap glXDestroyContext ;
