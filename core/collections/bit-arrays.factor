! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: math alien kernel kernel-internals sequences ;

: n>cell -5 shift 4 * ; inline

: cell/bit ( n alien -- byte bit )
    over n>cell alien-unsigned-4 swap 31 bitand ; inline

: set-bit ( ? byte bit -- byte )
    2^ rot [ bitor ] [ bitnot bitand ] if ; inline

: bits>bytes 7 + -3 shift ; inline

: bits>cells 31 + -5 shift ; inline

IN: bit-arrays

M: bit-array length array-capacity ;

M: bit-array nth-unsafe cell/bit 2^ bitand 0 > ;

M: bit-array nth bounds-check nth-unsafe ;

M: bit-array set-nth-unsafe
    [ cell/bit set-bit ] 2keep
    swap n>cell set-alien-unsigned-4 ;

M: bit-array set-nth bounds-check set-nth-unsafe ;

: clear-bits ( bit-array -- )
    dup length bits>cells [
        0 -rot 4 * set-alien-unsigned-4
    ] each-with ;

M: bit-array clone (clone) ;

: >bit-array ( seq -- bit-array ) ?{ } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ;

M: bit-array new drop <bit-array> ;

M: bit-array equal?
    over bit-array? [ sequence= ] [ 2drop f ] if ;
