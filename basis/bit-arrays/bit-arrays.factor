! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types accessors math alien.accessors kernel
kernel.private sequences sequences.private byte-arrays
parser prettyprint.custom fry ;
IN: bit-arrays

TUPLE: bit-array
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

<PRIVATE

: n>byte ( m -- n ) -3 shift ; inline

: byte/bit ( n alien -- byte bit )
    over n>byte alien-unsigned-1 swap 7 bitand ; inline

: set-bit ( ? byte bit -- byte )
    2^ rot [ bitor ] [ bitnot bitand ] if ; inline

: bits>cells ( m -- n ) 31 + -5 shift ; inline

: bits>bytes ( m -- n ) 7 + n>byte ; inline

: (set-bits) ( bit-array n -- )
    [ [ length bits>cells ] keep ] dip swap underlying>>
    '[ 2 shift [ _ _ ] dip set-alien-unsigned-4 ] each ; inline

PRIVATE>

: <bit-array> ( n -- bit-array )
    dup bits>bytes <byte-array> bit-array boa ; inline

M: bit-array length length>> ;

M: bit-array nth-unsafe
    [ >fixnum ] [ underlying>> ] bi* byte/bit bit? ;

M: bit-array set-nth-unsafe
    [ >fixnum ] [ underlying>> ] bi*
    [ byte/bit set-bit ] 2keep
    swap n>byte set-alien-unsigned-1 ;

: clear-bits ( bit-array -- ) 0 (set-bits) ;

: set-bits ( bit-array -- ) -1 (set-bits) ;

M: bit-array clone
    [ length>> ] [ underlying>> clone ] bi bit-array boa ;

: >bit-array ( seq -- bit-array )
    T{ bit-array f 0 B{ } } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ;

M: bit-array new-sequence drop <bit-array> ;

M: bit-array equal?
    over bit-array? [ sequence= ] [ 2drop f ] if ;

M: bit-array resize
    [ drop ] [
        [ bits>bytes ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    bit-array boa ;

M: bit-array byte-length length 7 + -3 shift ;

: ?{ \ } [ >bit-array ] parse-literal ; parsing

: integer>bit-array ( n -- bit-array )
    dup 0 = [
        <bit-array>
    ] [
        [ log2 1+ <bit-array> 0 ] keep
        [ dup 0 = ] [
            [ pick underlying>> pick set-alien-unsigned-1 ] keep
            [ 1+ ] [ -8 shift ] bi*
        ] until 2drop
    ] if ;

: bit-array>integer ( bit-array -- n )
    0 swap underlying>> dup length <reversed> [
        alien-unsigned-1 swap 8 shift bitor
    ] with each ;

INSTANCE: bit-array sequence

M: bit-array pprint-delims drop \ ?{ \ } ;
M: bit-array >pprint-sequence ;
M: bit-array pprint* pprint-object ;
