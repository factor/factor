! Copyright (C) 2007, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors byte-arrays endian
kernel kernel.private math math.bitwise parser sequences
sequences.private vocabs.loader ;
IN: bit-arrays

TUPLE: bit-array
    { length array-capacity read-only }
    { underlying byte-array read-only } ;

<PRIVATE

: n>byte ( m -- n ) -3 shift ; inline

: bit/byte ( n -- bit byte ) [ 7 bitand ] [ n>byte ] bi ; inline

: bit-index ( n bit-array -- bit# byte# byte-array )
    [ { integer-array-capacity } declare integer>fixnum bit/byte ]
    [ underlying>> ] bi* ; inline

: bits>cells ( m -- n ) 31 + -5 shift ; inline

: bits>bytes ( m -- n ) 7 + n>byte ; inline

: (set-bits) ( bit-array n -- )
    [ [ length bits>cells ] keep ] dip swap underlying>>
    '[ [ _ _ ] dip 4 * set-alien-unsigned-4 ] each-integer ; inline

: zero-end-bits ( bit-array -- bit-array )
    ! Zero bits after the end.
    dup underlying>> [ ] [
        [
            length 8 * over length -
            8 swap - -1 swap shift bitnot
        ]
        [ last bitand ]
        [ set-last ]
        tri
    ] if-empty ; inline

:: toggle-bit ( ? n x -- y )
    x n ? [ set-bit ] [ clear-bit ] if ; inline

PRIVATE>

ERROR: bad-array-length n ;

: <bit-array> ( n -- bit-array )
    dup 0 < [ bad-array-length ] when
    dup bits>bytes <byte-array>
    bit-array boa ; inline

M: bit-array length length>> ; inline

M: bit-array nth-unsafe
    bit-index nth-unsafe swap bit? ; inline

M: bit-array set-nth-unsafe
    bit-index [ toggle-bit ] change-nth-unsafe ; inline

GENERIC: clear-bits ( bit-array -- )

M: bit-array clear-bits 0 (set-bits) ; inline

GENERIC: set-bits ( bit-array -- )

M: bit-array set-bits -1 (set-bits) ; inline

M: bit-array clone
    [ length>> ] [ underlying>> clone ] bi bit-array boa ; inline

: >bit-array ( seq -- bit-array )
    T{ bit-array f 0 B{ } } clone-like ; inline

M: bit-array like drop dup bit-array? [ >bit-array ] unless ; inline

M: bit-array new-sequence drop <bit-array> ; inline

M: bit-array equal?
    over bit-array? [
        2dup 2length dupd = [
            [ [ underlying>> ] bi@ ] dip 8 mod [ sequence= ] [
                [ [ unclip-slice ] bi@ swapd ] dip
                '[ _ bits ] bi@ = [ sequence= ] [ 2drop f ] if
            ] if-zero
        ] [ 3drop f ] if
    ] [ 2drop f ] if ;

M: bit-array resize
    dupd [ bits>bytes ] [ underlying>> ] bi*
    resize-byte-array bit-array boa zero-end-bits ; inline

M: bit-array byte-length length bits>bytes ; inline

SYNTAX: ?{ \ } [ >bit-array ] parse-literal ;

: integer>bit-array ( n -- bit-array )
    dup 0 =
    [ <bit-array> ]
    [ dup log2 1 + [ nip ] [ bits>bytes >le ] 2bi bit-array boa ] if ;

: bit-array>integer ( bit-array -- n )
    underlying>> le> ;

INSTANCE: bit-array sequence

{ "bit-arrays" "prettyprint" } "bit-arrays.prettyprint" require-when
