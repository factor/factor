! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel accessors math alien.accessors
alien.c-types byte-arrays words io io.encodings
io.streams.byte-array io.streams.memory io.encodings.utf8
io.encodings.utf16 system alien strings cpu.architecture ;
IN: alien.strings

GENERIC# alien>string 1 ( c-ptr encoding -- string/f )

M: c-ptr alien>string
    >r <memory-stream> r> <decoder>
    "\0" swap stream-read-until drop ;

M: f alien>string
    drop ;

ERROR: invalid-c-string string ;

: check-string ( string -- )
    0 over memq? [ invalid-c-string ] [ drop ] if ;

GENERIC# string>alien 1 ( string encoding -- byte-array )

M: c-ptr string>alien drop ;

M: string string>alien
    over check-string
    <byte-writer>
    [ stream-write ]
    [ 0 swap stream-write1 ]
    [ stream>> >byte-array ]
    tri ;

: malloc-string ( string encoding -- alien )
    string>alien malloc-byte-array ;

PREDICATE: string-type < pair
    first2 [ "char*" = ] [ word? ] bi* and ;

M: string-type c-type ;

M: string-type heap-size
    drop "void*" heap-size ;

M: string-type c-type-align
    drop "void*" c-type-align ;

M: string-type c-type-stack-align?
    drop "void*" c-type-stack-align? ;

M: string-type unbox-parameter
    drop "void*" unbox-parameter ;

M: string-type unbox-return
    drop "void*" unbox-return ;

M: string-type box-parameter
    drop "void*" box-parameter ;

M: string-type box-return
    drop "void*" box-return ;

M: string-type stack-size
    drop "void*" stack-size ;

M: string-type c-type-reg-class
    drop int-regs ;

M: string-type c-type-boxer
    drop "void*" c-type-boxer ;

M: string-type c-type-unboxer
    drop "void*" c-type-unboxer ;

M: string-type c-type-boxer-quot
    second [ alien>string ] curry [ ] like ;

M: string-type c-type-unboxer-quot
    second [ string>alien ] curry [ ] like ;

M: string-type c-type-getter
    drop [ alien-cell ] ;

M: string-type c-type-setter
    drop [ set-alien-cell ] ;

TUPLE: utf16n ;

! Native-order UTF-16

: utf16n ( -- descriptor )
    little-endian? utf16le utf16be ? ; foldable

M: utf16n <decoder> drop utf16n <decoder> ;

M: utf16n <encoder> drop utf16n <encoder> ;

: alien>native-string ( alien -- string )
    os windows? [ utf16n ] [ utf8 ] if alien>string ;

: dll-path ( dll -- string )
    (dll-path) alien>native-string ;

: string>symbol ( str -- alien )
    [ os wince? [ utf16n ] [ utf8 ] if string>alien ]
    over string? [ call ] [ map ] if ;

{ "char*" utf8 } "char*" typedef
{ "char*" utf16n } "wchar_t*" typedef
"char*" "uchar*" typedef
