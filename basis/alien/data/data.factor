! (c)2009, 2010 Slava Pestov, Joe Groff bsd license
USING: accessors alien alien.c-types alien.arrays alien.strings
arrays byte-arrays cpu.architecture fry io io.encodings.binary
io.files io.streams.memory kernel libc math sequences words
macros combinators generalizations ;
IN: alien.data

GENERIC: require-c-array ( c-type -- )

M: array require-c-array first require-c-array ;

GENERIC: c-array-constructor ( c-type -- word ) foldable

GENERIC: c-(array)-constructor ( c-type -- word ) foldable

GENERIC: c-direct-array-constructor ( c-type -- word ) foldable

GENERIC: <c-array> ( len c-type -- array )

M: word <c-array>
    c-array-constructor execute( len -- array ) ; inline

GENERIC: (c-array) ( len c-type -- array )

M: word (c-array)
    c-(array)-constructor execute( len -- array ) ; inline

GENERIC: <c-direct-array> ( alien len c-type -- array )

M: word <c-direct-array>
    c-direct-array-constructor execute( alien len -- array ) ; inline

: malloc-array ( n type -- array )
    [ heap-size calloc ] [ <c-direct-array> ] 2bi ; inline

: (malloc-array) ( n type -- alien )
    [ heap-size * malloc ] [ <c-direct-array> ] 2bi ; inline

: <c-object> ( type -- array )
    heap-size <byte-array> ; inline

: (c-object) ( type -- array )
    heap-size (byte-array) ; inline

: malloc-object ( type -- alien )
    1 swap heap-size calloc ; inline

: (malloc-object) ( type -- alien )
    heap-size malloc ; inline

: malloc-byte-array ( byte-array -- alien )
    binary-object [ nip malloc dup ] 2keep memcpy ;

: memory>byte-array ( alien len -- byte-array )
    [ nip (byte-array) dup ] 2keep memcpy ;

: malloc-string ( string encoding -- alien )
    string>alien malloc-byte-array ;

M: memory-stream stream-read
    [
        [ index>> ] [ alien>> ] bi <displaced-alien>
        swap memory>byte-array
    ] [ [ + ] change-index drop ] 2bi ;

M: value-type c-type-rep drop int-rep ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-setter ( type -- quot )
    [ c-type-getter ] [ heap-size ] bi '[ @ swap _ memcpy ] ;

M: array c-type-boxer-quot
    unclip [ array-length ] dip [ <c-direct-array> ] 2curry ;

M: array c-type-unboxer-quot drop [ >c-ptr ] ;

ERROR: local-allocation-error ;

<PRIVATE

: (local-allot) ( size align -- alien ) local-allocation-error ;

: (cleanup-allot) ( -- )
    ! Inhibit TCO in order for the last word in the quotation
    ! to still be abl to access scope-allocated data.
    ;

MACRO: (local-allots) ( c-types -- quot )
    [ '[ _ [ heap-size ] [ c-type-align ] bi (local-allot) ] ] map [ ] join ;

MACRO: box-values ( c-types -- quot )
    [ c-type-boxer-quot ] map '[ _ spread ] ;

MACRO: out-parameters ( c-types -- quot )
    [ length ] [ [ '[ 0 _ alien-value ] ] map ] bi
    '[ _ nkeep _ spread ] ;

PRIVATE>

: with-scoped-allocation ( c-types quot -- )
    [ [ (local-allots) ] [ box-values ] bi ] dip call
    (cleanup-allot) ; inline

: with-out-parameters ( c-types quot finish -- values )
    [ [ drop (local-allots) ] [ swap out-parameters ] 2bi ] dip call
    (cleanup-allot) ; inline
