! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math alien kernel kernel.private sequences
sequences.private ;
IN: bit-arrays

<PRIVATE

: n>cell -5 shift 4 * ; inline

: cell/bit ( n alien -- byte bit )
    over n>cell alien-unsigned-4 swap 31 bitand ; inline

: set-bit ( ? byte bit -- byte )
    2^ rot [ bitor ] [ bitnot bitand ] if ; inline

: bits>bytes 7 + -3 shift ; inline

: bits>cells 31 + -5 shift ; inline

: (set-bits) ( bit-array n -- )
    over length bits>cells -rot [
        swap rot 4 * set-alien-unsigned-4
    ] 2curry each ; inline

PRIVATE>

M: bit-array length array-capacity ;

M: bit-array nth-unsafe cell/bit bit? ;

M: bit-array set-nth-unsafe
    [ cell/bit set-bit ] 2keep
    swap n>cell set-alien-unsigned-4 ;

: clear-bits ( bit-array -- ) 0 (set-bits) ;

: set-bits ( bit-array -- ) -1 (set-bits) ;

M: bit-array clone (clone) ;

: >bit-array ( seq -- bit-array ) ?{ } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ;

M: bit-array new drop <bit-array> ;

M: bit-array equal?
    over bit-array? [ sequence= ] [ 2drop f ] if ;

INSTANCE: bit-array sequence
