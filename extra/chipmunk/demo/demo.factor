! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data chipmunk.ffi
classes.struct game.loop game.worlds kernel literals locals
math method-chains opengl.gl random sequences specialized-arrays
ui ui.gadgets.worlds ui.pixel-formats ;
SPECIALIZED-ARRAY: void*
IN: chipmunk.demo

CONSTANT: image-width      188
CONSTANT: image-height     35
CONSTANT: image-row-length 24

CONSTANT: image-bitmap B{
    15 -16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 -64 15 63 -32 -2 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 0 31 -64 15 127 -125 -1 -128 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 0 127 -64 15 127 15 -1 -64 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 -64 15 -2
    31 -1 -64 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 -64 0 -4 63 -1 -32 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 1 -1 -64 15 -8 127 -1 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    1 -1 -64 0 -8 -15 -1 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -31 -1 -64 15 -8 -32
    -1 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 -15 -1 -64 9 -15 -32 -1 -32 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0 31 -15 -1 -64 0 -15 -32 -1 -32 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 63 -7 -1 -64 9 -29 -32 127 -61 -16 63 15 -61 -1 -8 31 -16 15 -8 126 7 -31
    -8 31 -65 -7 -1 -64 9 -29 -32 0 7 -8 127 -97 -25 -1 -2 63 -8 31 -4 -1 15 -13
    -4 63 -1 -3 -1 -64 9 -29 -32 0 7 -8 127 -97 -25 -1 -2 63 -8 31 -4 -1 15 -13
    -2 63 -1 -3 -1 -64 9 -29 -32 0 7 -8 127 -97 -25 -1 -1 63 -4 63 -4 -1 15 -13
    -2 63 -33 -1 -1 -32 9 -25 -32 0 7 -8 127 -97 -25 -1 -1 63 -4 63 -4 -1 15 -13
    -1 63 -33 -1 -1 -16 9 -25 -32 0 7 -8 127 -97 -25 -1 -1 63 -4 63 -4 -1 15 -13
    -1 63 -49 -1 -1 -8 9 -57 -32 0 7 -8 127 -97 -25 -8 -1 63 -2 127 -4 -1 15 -13
    -1 -65 -49 -1 -1 -4 9 -57 -32 0 7 -8 127 -97 -25 -8 -1 63 -2 127 -4 -1 15 -13
    -1 -65 -57 -1 -1 -2 9 -57 -32 0 7 -8 127 -97 -25 -8 -1 63 -2 127 -4 -1 15 -13
    -1 -1 -57 -1 -1 -1 9 -57 -32 0 7 -1 -1 -97 -25 -8 -1 63 -1 -1 -4 -1 15 -13 -1
    -1 -61 -1 -1 -1 -119 -57 -32 0 7 -1 -1 -97 -25 -8 -1 63 -1 -1 -4 -1 15 -13 -1
    -1 -61 -1 -1 -1 -55 -49 -32 0 7 -1 -1 -97 -25 -8 -1 63 -1 -1 -4 -1 15 -13 -1
    -1 -63 -1 -1 -1 -23 -49 -32 127 -57 -1 -1 -97 -25 -1 -1 63 -1 -1 -4 -1 15 -13
    -1 -1 -63 -1 -1 -1 -16 -49 -32 -1 -25 -1 -1 -97 -25 -1 -1 63 -33 -5 -4 -1 15
    -13 -1 -1 -64 -1 -9 -1 -7 -49 -32 -1 -25 -8 127 -97 -25 -1 -1 63 -33 -5 -4 -1
    15 -13 -1 -1 -64 -1 -13 -1 -32 -49 -32 -1 -25 -8 127 -97 -25 -1 -2 63 -49 -13
    -4 -1 15 -13 -1 -1 -64 127 -7 -1 -119 -17 -15 -1 -25 -8 127 -97 -25 -1 -2 63
    -49 -13 -4 -1 15 -13 -3 -1 -64 127 -8 -2 15 -17 -1 -1 -25 -8 127 -97 -25 -1
    -8 63 -49 -13 -4 -1 15 -13 -3 -1 -64 63 -4 120 0 -17 -1 -1 -25 -8 127 -97 -25
    -8 0 63 -57 -29 -4 -1 15 -13 -4 -1 -64 63 -4 0 15 -17 -1 -1 -25 -8 127 -97
    -25 -8 0 63 -57 -29 -4 -1 -1 -13 -4 -1 -64 31 -2 0 0 103 -1 -1 -57 -8 127 -97
    -25 -8 0 63 -57 -29 -4 -1 -1 -13 -4 127 -64 31 -2 0 15 103 -1 -1 -57 -8 127
    -97 -25 -8 0 63 -61 -61 -4 127 -1 -29 -4 127 -64 15 -8 0 0 55 -1 -1 -121 -8
    127 -97 -25 -8 0 63 -61 -61 -4 127 -1 -29 -4 63 -64 15 -32 0 0 23 -1 -2 3 -16
    63 15 -61 -16 0 31 -127 -127 -8 31 -1 -127 -8 31 -128 7 -128 0 0 }

:: get-pixel ( x y -- z )
    x -3 shift y image-row-length * + image-bitmap nth
    x bitnot 7 bitand neg shift 1 bitand 1 = ;

:: make-ball ( x y -- shape )
    cpBodyAlloc 1.0 NAN: 0 cpBodyInit
    x y cpv >>p :> body
    cpCircleShapeAlloc body 0.95 0 0 cpv cpCircleShapeInit
    dup shape>>
        0 >>e
        0 >>u
        drop ;

TUPLE: chipmunk-world < game-world
    space ;

AFTER: chipmunk-world tick-game-world
    space>> 1.0 60.0 / cpSpaceStep ;

SPECIALIZED-ARRAY: cpContact
M:: chipmunk-world draw-world* ( world -- )
    1 1 1 0 glClearColor
    GL_COLOR_BUFFER_BIT glClear
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    -320 320 -240 240 -1 1 glOrtho
    0.5 0.5 0 glTranslatef
    GL_VERTEX_ARRAY glEnableClientState

    world space>> :> space

    3 glPointSize
    0 0 0 glColor3f
    GL_POINTS glBegin
    space bodies>>
    [ num>> ] [ arr>> swap void* <c-direct-array> ] bi [
        cpBody memory>struct p>> [ x>> ] [ y>> ] bi glVertex2f
    ] each
    glEnd

    2 glPointSize
    1 0 0 glColor3f
    GL_POINTS glBegin
    space arbiters>>
    [ num>> ] [ arr>> swap void* <c-direct-array> ] bi [
        cpArbiter memory>struct
        [ numContacts>> ] [ contacts>> >c-ptr swap cpContact <c-direct-array> ] bi [
            p>> [ x>> ] [ y>> ] bi glVertex2f
        ] each
    ] each
    glEnd ;

M:: chipmunk-world begin-game-world ( world -- )
    cpInitChipmunk

    cpSpaceAlloc cpSpaceInit :> space

    world space >>space drop
    space 2.0 10000 cpSpaceResizeActiveHash
    space 1 >>iterations drop

    image-height <iota> [| y |
        image-width <iota> [| x |
            x y get-pixel [
                x image-width 2 / - 0.05 random-unit * + 2 *
                image-height 2 / y - 0.05 random-unit * + 2 *
                make-ball :> shape
                space shape shape>> body>> cpSpaceAddBody drop
                space shape cpSpaceAddShape drop
            ] when
        ] each
    ] each

    space cpBodyAlloc NAN: 0 dup cpBodyInit cpSpaceAddBody :> body
    body -1000 -10 cpv >>p drop
    body 400 0 cpv >>v drop

    space cpCircleShapeAlloc [ body 8 0 0 cpv cpCircleShapeInit cpSpaceAddShape drop ] keep
        :> shape
    shape shape>>
        0 >>e
        0 >>u
        drop ;

M: chipmunk-world end-game-world
    space>>
    [ cpSpaceFreeChildren ]
    [ cpSpaceFree ] bi ;

: chipmunk-demo ( -- )
    [
        f
        T{ game-attributes
           { world-class chipmunk-world }
           { title "Chipmunk Physics Demo" }
           { pixel-format-attributes
             { windowed double-buffered }
           }
           { pref-dim { 640 480 } }
           { tick-interval-nanos $[ 60 fps ] }
        }
        clone
        open-window
    ] with-ui ;

MAIN: chipmunk-demo
