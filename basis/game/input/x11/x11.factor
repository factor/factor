USING: alien.c-types alien.syntax arrays bit-arrays game.input
kernel namespaces sequences x11 x11.xlib ;
IN: game.input.x11

SINGLETON: x11-game-input-backend

x11-game-input-backend game-input-backend set-global

LIBRARY: xlib
FUNCTION: int XQueryKeymap ( Display* display, char[32] keys_return ) ;

CONSTANT: x>hid-bit-order {
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
    90 89 99 0 0 0 68 69 
    0 0 0 0 0 0 0 88 
    228 84 70 0 0 74 82 75 
    80 79 77 81 78 73 76 127 
    129 128 102 103 0 72 0 0 
    0 0 227 231 0 0 0 0 
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

M: x11-game-input-backend (open-game-input) ; ! assume X was already started for now
M: x11-game-input-backend (close-game-input) ; ! let someone else stop X
M: x11-game-input-backend (reset-game-input) ; ! nothing to reset at this point

! No controller support yet--if this works, I shouldn't even need to define the other methods
M: x11-game-input-backend get-controllers f ;


: x-bits>hid-bits ( bit-array -- bit-array )
        256 iota [ 2array ] 2map [ first ] filter [ second ] map
        x>hid-bit-order [ nth ] with map
        ?{ } swap [ t swap pick set-nth ] each ;
        
M: x11-game-input-backend read-keyboard
        dpy get 256 <bit-array> [ XQueryKeymap drop ] keep
        x-bits>hid-bits keyboard-state boa ;

M: x11-game-input-backend read-mouse
        0 0 0 0 ?{ f f f } mouse-state boa ;

M: x11-game-input-backend reset-mouse ;