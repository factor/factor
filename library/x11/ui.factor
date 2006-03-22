! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: arrays errors freetype gadgets gadgets-launchpad
gadgets-layouts gadgets-listener hashtables kernel
kernel-internals math namespaces opengl sequences x11 ;

! In the X11 backend, world-handle is a pair { window context }.
! The window is an X11 window ID, and the context is a
! GLX context pointer.

M: world expose-event ( event world -- ) nip draw-world ;

M: world resize-event ( event world -- )
    >r
    dup XConfigureEvent-width swap XConfigureEvent-height 0
    3array
    r> set-gadget-dim ;

M: world button-down-event ( event world -- )
    drop XButtonEvent-button send-button-down ;

M: world button-up-event ( event world -- )
    drop XButtonEvent-button send-button-up ;

M: world motion-event ( event world -- )
    >r dup XMotionEvent-x swap XMotionEvent-y 0 3array r>
    move-hand ;

M: world key-event ( event world -- ) 2drop ;

: close-box? ( event -- )
    dup XClientMessageEvent-type "WM_PROTOCOLS" x-atom =
    swap XClientMessageEvent-data "WM_DELETE_WINDOW" x-atom =
    and ;

M: world client-event ( event world -- )
    swap close-box? [
        dup close-world world-handle destroy-window*
    ] [
        drop
    ] if ;

: gadget-window ( world -- window )
    dup rect-dim first2 choose-visual [
        create-window 2dup map-window*
    ] keep create-context 2array swap set-world-handle ;

IN: gadgets

: draw-handle ( handle -- ) first windows get hash draw-world ;

: in-window ( gadget status dim title -- )
    >r <world> r> drop gadget-window ;

: select-gl-context ( handle -- )
    dpy get swap first2 glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

: flush-gl-context ( handle -- )
    dpy get swap first glXSwapBuffers ;

IN: shells

: ui ( -- )
    [
        f [
            launchpad-window
            listener-window
            event-loop
        ] with-x
    ] with-freetype ;

IN: kernel

! : default-shell "DISPLAY" os-env empty? "tty" "ui" ? ;
