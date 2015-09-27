USING: sequences sequences.private math
accessors alien.c-types ;
IN: game.input.dinput.keys-array

TUPLE: keys-array
    { underlying sequence read-only }
    { length integer read-only } ;
C: <keys-array> keys-array

: >key ( byte -- ? )
    0x80 bitand c-bool> ;

M: keys-array length length>> ;
M: keys-array nth-unsafe underlying>> nth-unsafe >key ;

INSTANCE: keys-array sequence
