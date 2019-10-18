! Copyright (C) 2005, 2006 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors kernel namespaces sequences ;

: choose-visual ( -- XVisualInfo* )
    dpy get scr get
    GLX_RGBA GLX_DOUBLEBUFFER 0 3array >int-array
    glXChooseVisual
    [ "Could not get a double-buffered GLX RGBA visual" throw ] unless* ;

: create-context ( XVisualInfo* -- GLXContext )
    >r dpy get r> f 1 glXCreateContext
    [ "Failed to create GLX context" throw ] unless* ;
    
: destroy-context ( GLXContext -- )
    dpy get swap glXDestroyContext ;
