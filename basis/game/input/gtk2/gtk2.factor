! Copyright (C) 2010 Erik Charlebois, William Schlieper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax arrays
assocs bit-arrays destructors game.input gdk2.ffi
io.encodings.binary io.files kernel linux.input-events
linux.input-events.ffi math namespaces sequences
system unix.ffi x11.xlib ;
IN: game.input.gtk2

SINGLETON: gtk2-game-input-backend

gtk2-game-input-backend game-input-backend set-global

LIBRARY: gdk2
FUNCTION: Display* gdk_x11_display_get_xdisplay ( GdkDisplay* display )

TUPLE: linux-controller < controller path meta state thread fd buttons quit? ;
: <linux-controller> ( path -- controller )
    linux-controller new
        swap >>path
        dup path>> get-event-device-info >>meta
        dup meta>> "path" of binary <file-reader> handle>> fd>> >>fd
        H{ } clone >>state
        dup meta>> "capabilities" of EV_KEY of keys seq>explode-positions >>buttons ; inline
        ! tuck state>> '[ _ _ read-events ] in-thread ;

M: linux-controller dispose* fd>> close drop ;

TUPLE: linux-controller-state < controller-state abs ;

: get-dpy ( -- dpy )
    gdk_display_get_default [ gdk_x11_display_get_xdisplay ] [
        "No default display." throw
    ] if* ;

M: gtk2-game-input-backend (open-game-input)
    reset-mouse ;

M: gtk2-game-input-backend (close-game-input)
    ;

M: gtk2-game-input-backend (reset-game-input)
    ;

M: gtk2-game-input-backend get-controllers
    get-input-events-joysticks values [ <linux-controller> ] map ;

M: gtk2-game-input-backend product-string
    meta>> "name" of ;

M: gtk2-game-input-backend product-id
    meta>> "id" of ;

M: gtk2-game-input-backend instance-id
    drop f ;

M: gtk2-game-input-backend read-controller
    [ linux-controller-state new ] dip
    [ fd>> ] [ meta>> ] bi
    [ drop evdev-get-key seq>explode-positions [ <INPUT_KEY> ] zip-with >>buttons ]
    [ "capabilities" of EV_ABS of [ [ first first evdev-get-abs ] [ first ] bi swap 2array ] with map >>abs ] 2bi ;

M: gtk2-game-input-backend calibrate-controller
    drop ;

M: gtk2-game-input-backend vibrate-controller
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

M: gtk2-game-input-backend read-keyboard
    get-dpy 256 <bit-array> [ XQueryKeymap drop ] keep
    x-bits>hid-bits keyboard-state boa ;

: query-pointer ( -- x y buttons )
    get-dpy dup XDefaultRootWindow
    { int int int int int int int }
    [ XQueryPointer drop ] with-out-parameters
    [ 4drop ] 3dip ;

M: gtk2-game-input-backend read-mouse
    query-pointer
    mouse-state new
    swap 256 /i >>buttons
    swap 400 - >>dy
    swap 400 - >>dx
    0 >>scroll-dy 0 >>scroll-dx ;

M: gtk2-game-input-backend reset-mouse
    get-dpy dup XDefaultRootWindow dup
    0 0 0 0 400 400 XWarpPointer drop ;
