! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: math alien kernel byte-arrays ;

: n>cell -5 shift 4 * ; inline

: cell/bit ( n alien -- byte bit )
    over n>cell alien-unsigned-4 swap 31 bitand ; inline

: set-bit ( ? byte bit -- byte )
    2^ rot [ bitor ] [ bitnot bitand ] if ; inline

: bits>bytes 7 + 8 /i ; inline

IN: bit-arrays
USING: sequences ;

TUPLE: bit-array store length ;

M: bit-array underlying bit-array-store ;

M: bit-array set-underlying set-bit-array-store ;

C: bit-array ( len -- bit-array )
    [ set-bit-array-length ] 2keep
    swap bits>bytes 4 align <byte-array>
    over set-bit-array-store ;

M: bit-array length bit-array-length ;

M: bit-array nth-unsafe
    underlying cell/bit 2^ bitand 0 > ;

M: bit-array nth bounds-check nth-unsafe ;

M: bit-array set-nth-unsafe
    underlying
    [ cell/bit set-bit ] 2keep
    swap n>cell set-alien-unsigned-4 ;

M: bit-array set-nth bounds-check set-nth-unsafe ;

: clear-bits ( bit-array -- )
    underlying [ drop 0 ] inject ;

M: bit-array clone clone-resizable ;

: >bit-array ( seq -- bit-array ) ?{ } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ;

M: bit-array new drop <bit-array> ;

M: bit-array equal?
    over bit-array? [ sequence= ] [ 2drop f ] if ;
