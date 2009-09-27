! (c)2009 Slava Pestov, Joe Groff bsd license
USING: accessors alien alien.c-types alien.strings arrays
byte-arrays cpu.architecture fry io io.encodings.binary
io.files io.streams.memory kernel libc math sequences ;
IN: alien.data

GENERIC: require-c-array ( c-type -- )

M: array require-c-array first require-c-array ;

GENERIC: c-array-constructor ( c-type -- word )

GENERIC: c-(array)-constructor ( c-type -- word )

GENERIC: c-direct-array-constructor ( c-type -- word )

GENERIC: <c-array> ( len c-type -- array )

M: c-type-name <c-array>
    c-array-constructor execute( len -- array ) ; inline

GENERIC: (c-array) ( len c-type -- array )

M: c-type-name (c-array)
    c-(array)-constructor execute( len -- array ) ; inline

GENERIC: <c-direct-array> ( alien len c-type -- array )

M: c-type-name <c-direct-array>
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
    dup byte-length [ nip malloc dup ] 2keep memcpy ;

: memory>byte-array ( alien len -- byte-array )
    [ nip (byte-array) dup ] 2keep memcpy ;

: malloc-string ( string encoding -- alien )
    string>alien malloc-byte-array ;

: malloc-file-contents ( path -- alien len )
    binary file-contents [ malloc-byte-array ] [ length ] bi ;

M: memory-stream stream-read
    [
        [ index>> ] [ alien>> ] bi <displaced-alien>
        swap memory>byte-array
    ] [ [ + ] change-index drop ] 2bi ;

: byte-array>memory ( byte-array base -- )
    swap dup byte-length memcpy ; inline

: >c-bool ( ? -- int ) 1 0 ? ; inline

: c-bool> ( int -- ? ) 0 = not ; inline

M: value-type c-type-rep drop int-rep ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-setter ( type -- quot )
    [ c-type-getter ] [ c-type-unboxer-quot ] [ heap-size ] tri
    '[ @ swap @ _ memcpy ] ;

