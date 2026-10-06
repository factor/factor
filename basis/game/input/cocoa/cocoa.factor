! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs bit-arrays game.input kernel locals math
namespaces sequences ui.backend.input-state ;
IN: game.input.cocoa

! Physical virtual keycodes from HIToolbox/Events.h, mapped to USB HID.
! Window events do not require global Input Monitoring permission.
CONSTANT: cocoa>hid {
    4 22 7 9 11 10 29 27
    6 25 100 5 20 26 8 21
    28 23 30 31 32 33 35 34
    46 38 36 45 37 39 48 18
    24 47 12 19 40 15 13 52
    14 51 49 54 56 17 16 55
    43 44 53 42 0 41 231 227
    225 57 226 224 229 230 228 0
    108 99 0 85 0 87 0 83
    128 129 127 84 88 0 86 109
    110 103 98 89 90 91 92 93
    94 95 111 96 97 137 135 133
    62 63 64 60 65 66 145 68
    144 104 107 105 0 67 0 69
    0 106 117 74 75 76 61 77
    59 78 58 80 79 81 82 0
}

:: cocoa-keycodes>hid ( keycodes -- bits )
    256 <bit-array> :> bits
    keycodes keys [| code |
        code 0 >= code cocoa>hid length < and [
            code cocoa>hid nth dup zero?
            [ drop ] [ t swap bits set-nth ] if
        ] when
    ] each
    bits ;

: cocoa-keyboard ( -- keyboard )
    current-input-state get-global keycodes>> cocoa-keycodes>hid keyboard-state boa ;

: cocoa-mouse ( -- mouse )
    current-input-state get-global
    [ motion>> first2 ] [ scroll>> first2 ] [ buttons>> clone ] tri mouse-state boa ;
