! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math alien.accessors kernel kernel.private sequences
sequences.private ;
IN: bit-arrays

<PRIVATE

: n>byte -3 shift ; inline

: byte/bit ( n alien -- byte bit )
    over n>byte alien-unsigned-1 swap 7 bitand ; inline

: set-bit ( ? byte bit -- byte )
    2^ rot [ bitor ] [ bitnot bitand ] if ; inline

: bits>cells 31 + -5 shift ; inline

: (set-bits) ( bit-array n -- )
    over length bits>cells -rot [
        spin 4 * set-alien-unsigned-4
    ] 2curry each ; inline

PRIVATE>

M: bit-array length array-capacity ;

M: bit-array nth-unsafe
    >r >fixnum r> byte/bit bit? ;

M: bit-array set-nth-unsafe
    >r >fixnum r>
    [ byte/bit set-bit ] 2keep
    swap n>byte set-alien-unsigned-1 ;

: clear-bits ( bit-array -- ) 0 (set-bits) ;

: set-bits ( bit-array -- ) -1 (set-bits) ;

M: bit-array clone (clone) ;

: >bit-array ( seq -- bit-array ) ?{ } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ;

M: bit-array new drop <bit-array> ;

M: bit-array equal?
    over bit-array? [ sequence= ] [ 2drop f ] if ;

M: bit-array resize
    resize-bit-array ;

INSTANCE: bit-array sequence
