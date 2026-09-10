! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs bit-arrays classes.mixin game.input
game.input.linux kernel locals math namespaces sequences
ui.backend.gtk4.input-state ;
IN: game.input.gtk4

SINGLETON: gtk4-game-input-backend
INSTANCE: gtk4-game-input-backend linux-game-input-backend

gtk4-game-input-backend game-input-backend set-global

! On Linux both GDK X11 and Wayland report XKB keycodes (evdev + 8).
! Keep the same USB HID mapping as the existing X11 game-input backend.
CONSTANT: xkb>hid {
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
    }

:: keycodes>hid-bits ( keycodes -- bits )
    256 <bit-array> :> bits
    keycodes keys [| code |
        code 0 >= code xkb>hid length < and [
            code xkb>hid nth dup 0 > [ t swap bits set-nth ] [ drop ] if
        ] when
    ] each
    bits ;

M: gtk4-game-input-backend (open-game-input) ;
M: gtk4-game-input-backend (close-game-input) ;
M: gtk4-game-input-backend (reset-game-input) clear-input-state ;

M: gtk4-game-input-backend read-keyboard
    current-input-state get-global keycodes>> keycodes>hid-bits keyboard-state boa ;

M: gtk4-game-input-backend read-mouse
    current-input-state get-global
    [ motion>> first2 ] [ scroll>> first2 ] [ buttons>> clone ] tri mouse-state boa ;

M: gtk4-game-input-backend reset-mouse reset-pointer-deltas ;
