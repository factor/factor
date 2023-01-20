! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types alien.strings
arrays byte-arrays combinators combinators.short-circuit
cpu.architecture generalizations io io.streams.memory kernel
libc math parser sequences stack-checker.dependencies summary
words ;
IN: alien.data

: <ref> ( value c-type -- c-ptr )
    [ heap-size (byte-array) ] keep
    '[ 0 _ set-alien-value ] keep ; inline

: deref ( c-ptr c-type -- value )
    [ 0 ] dip alien-value ; inline

: little-endian? ( -- ? ) 1 int <ref> char deref 1 = ; foldable

GENERIC: c-array-constructor ( c-type -- word ) foldable

GENERIC: c-(array)-constructor ( c-type -- word ) foldable

GENERIC: c-direct-array-constructor ( c-type -- word ) foldable

GENERIC: c-array-type ( c-type -- word ) foldable

GENERIC: c-array-type? ( c-type -- word ) foldable

GENERIC: c-array? ( obj c-type -- ? ) foldable

M: word c-array?
    c-array-type? execute( seq -- array ) ; inline

M: pointer c-array?
    drop void* c-array? ;

GENERIC: >c-array ( seq c-type -- array )

M: word >c-array
    c-array-type new clone-like ; inline

M: pointer >c-array
    drop void* >c-array ;

GENERIC: <c-array> ( len c-type -- array )

M: word <c-array>
    c-array-constructor execute( len -- array ) ; inline

M: pointer <c-array>
    drop void* <c-array> ;

GENERIC: (c-array) ( len c-type -- array )

M: word (c-array)
    c-(array)-constructor execute( len -- array ) ; inline

M: pointer (c-array)
    drop void* (c-array) ;

GENERIC: <c-direct-array> ( alien len c-type -- array )

M: word <c-direct-array>
    c-direct-array-constructor execute( alien len -- array ) ; inline

M: pointer <c-direct-array>
    drop void* <c-direct-array> ;

SYNTAX: c-array{ \ } [ unclip >c-array ] parse-literal ;

SYNTAX: c-array@
    scan-object [ scan-object scan-object ] dip
    <c-direct-array> suffix! ;

ERROR: bad-byte-array-length byte-array type ;

M: bad-byte-array-length summary
    drop "Byte array length doesn't divide type width" ;

: cast-array ( byte-array c-type -- array )
    [ binary-object ] dip [ heap-size /mod 0 = ] keep swap
    [ <c-direct-array> ] [ bad-byte-array-length ] if ; inline

: malloc-array ( n c-type -- array )
    [ heap-size calloc ] [ <c-direct-array> ] 2bi ; inline

: malloc-like ( seq c-type -- malloc )
    [ dup length ] dip malloc-array [ 0 swap copy ] keep ;

: malloc-byte-array ( byte-array -- alien )
    binary-object [ nip malloc dup ] 2keep memcpy ;

: memory>byte-array ( alien len -- byte-array )
    [ nip (byte-array) dup ] 2keep memcpy ;

: malloc-string ( string encoding -- alien )
    string>alien malloc-byte-array ;

M:: memory-stream stream-read-unsafe ( n buf stream -- count )
    stream alien>> :> src
    buf src n memcpy
    n src <displaced-alien> stream alien<<
    n ; inline

M: value-type c-type-rep drop int-rep ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-copier
    heap-size '[ _ memory>byte-array ] ;

M: value-type c-type-setter
    [ c-type-getter ] [ heap-size ] bi '[ @ swap _ memcpy ] ;

M: array c-type-boxer-quot
    unclip [ array-length ] dip [ <c-direct-array> ] 2curry ;

M: array c-type-unboxer-quot drop [ >c-ptr ] ;

ERROR: local-allocation-error ;

<PRIVATE

: local-allot ( size align -- alien ) local-allocation-error ;

: cleanup-allot ( -- )
    ! Inhibit TCO in order for the last word in the quotation
    ! to still be able to access scope-allocated data.
    ;

MACRO: simple-local-allot-quot ( c-type -- quot )
    [ add-depends-on-c-type ]
    [ dup '[ _ heap-size _ c-type-align local-allot ] ] bi ;

: hairy-local-allot-quot ( c-type initial -- quot )
    over '[ _ simple-local-allot-quot _ over 0 _ set-alien-value ] ;

: hairy-local-allot? ( obj -- ? )
    {
        [ array? ]
        [ length 3 = ]
        [ second initial: eq? ]
    } 1&& ;

MACRO: hairy-local-allot ( obj -- quot )
    dup hairy-local-allot? [
        first3 nip hairy-local-allot-quot
    ] [
        '[ _ simple-local-allot-quot ]
    ] if ;

MACRO: local-allots ( c-types -- quot )
    [ '[ _ hairy-local-allot ] ] map [ ] join ;

MACRO: box-values ( c-types -- quot )
    [ c-type-boxer-quot ] map '[ _ spread ] ;

MACRO: out-parameters ( c-types -- quot )
    [ dup hairy-local-allot? [ first ] when ] map
    [ length ] [ [ '[ 0 _ alien-copy-value ] ] map ] bi
    '[ _ nkeep _ spread ] ;

PRIVATE>

: with-scoped-allocation ( c-types quot -- )
    [ [ local-allots ] [ box-values ] bi ] dip call
    cleanup-allot ; inline

: with-out-parameters ( c-types quot -- values... )
    [ drop local-allots ] [ swap out-parameters ] 2bi
    cleanup-allot ; inline

GENERIC: binary-zero? ( value -- ? )

M: object binary-zero? drop f ; inline
M: f binary-zero? drop t ; inline
M: integer binary-zero? zero? ; inline
M: math:float binary-zero? double>bits zero? ; inline
M: complex binary-zero? >rect [ binary-zero? ] both? ; inline
