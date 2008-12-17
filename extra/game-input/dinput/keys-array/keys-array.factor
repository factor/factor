USING: sequences sequences.private math alien.c-types
accessors ;
IN: game-input.dinput.keys-array

TUPLE: keys-array underlying ;
C: <keys-array> keys-array

: >key ( byte -- ? )
    HEX: 80 bitand c-bool> ;

M: keys-array length underlying>> length ;
M: keys-array nth-unsafe underlying>> nth-unsafe >key ;

INSTANCE: keys-array sequence

