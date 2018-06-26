! Copyright (C) 2010 Erik Charlebois, William Schlieper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax assocs
bit-arrays game.input gdk.ffi generalizations kernel math
namespaces sequences system x11.xlib ;
IN: game.input.gtk

SINGLETON: gtk-game-input-backend

gtk-game-input-backend game-input-backend set-global

LIBRARY: gdk
FUNCTION: Display* gdk_x11_display_get_xdisplay ( GdkDisplay* display )

: get-dpy ( -- dpy )
    gdk_display_get_default [ gdk_x11_display_get_xdisplay ] [
        "No default display." throw
    ] if* ;

M: gtk-game-input-backend (open-game-input)
    reset-mouse ;

M: gtk-game-input-backend (close-game-input)
    ;

M: gtk-game-input-backend (reset-game-input)
    ;

M: gtk-game-input-backend get-controllers
    { } ;

M: gtk-game-input-backend product-string
    drop "" ;

M: gtk-game-input-backend product-id
    drop f ;

M: gtk-game-input-backend instance-id
    drop f ;

M: gtk-game-input-backend read-controller
    drop controller-state new ;

M: gtk-game-input-backend calibrate-controller
    drop ;

M: gtk-game-input-backend vibrate-controller
    3drop ;

HOOK: x>hid-bit-order os ( -- x )

M: linux x>hid-bit-order
    {
        0 0 0 0 0 0 0 0
        0 41 30 31 32 33 34 35
        36 37 38 39 45 46 42 43
        20 26 8 21 23 28 24 12
        18 19 47 48 40 224 4 22
        7 9 10 11 13 14 15 51
        52 53 225 49 29 27 6 25
        5 17 16 54 55 56 229 85
        226 44 57 58 59 60 61 62
        63 64 65 66 67 83 71 95
        96 97 86 92 93 94 87 91
        90 89 98 99 0 0 0 68
        69 0 0 0 0 0 0 0
        88 228 84 70 0 0 74 82
        75 80 79 77 81 78 73 76
        127 129 128 102 103 0 72 0
        0 0 0 227 231 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0
    } ; inline

: x-bits>hid-bits ( bit-array -- bit-array )
    256 <iota> zip [ first ] filter values
    x>hid-bit-order [ nth ] curry map
    256 <bit-array> swap [ t swap pick set-nth ] each ;

M: gtk-game-input-backend read-keyboard
    get-dpy 256 <bit-array> [ XQueryKeymap drop ] keep
    x-bits>hid-bits keyboard-state boa ;

: query-pointer ( -- x y buttons )
    get-dpy dup XDefaultRootWindow
    { int int int int int int int }
    [ XQueryPointer drop ] with-out-parameters
    [ 4drop ] 3dip ;

M: gtk-game-input-backend read-mouse
    query-pointer
    mouse-state new
    swap 256 /i >>buttons
    swap 400 - >>dy
    swap 400 - >>dx
    0 >>scroll-dy 0 >>scroll-dx ;

M: gtk-game-input-backend reset-mouse
    get-dpy dup XDefaultRootWindow dup
    0 0 0 0 400 400 XWarpPointer drop ;
