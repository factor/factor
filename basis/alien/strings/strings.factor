! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel accessors math alien.accessors
alien.c-types byte-arrays words io io.encodings
io.encodings.utf8 io.streams.byte-array io.streams.memory system
alien strings cpu.architecture fry vocabs.loader combinators ;
IN: alien.strings

GENERIC# alien>string 1 ( c-ptr encoding -- string/f )

M: c-ptr alien>string
    [ <memory-stream> ] [ <decoder> ] bi*
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

M: string-type c-type-class
    drop object ;

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
    second '[ _ alien>string ] ;

M: string-type c-type-unboxer-quot
    second '[ _ string>alien ] ;

M: string-type c-type-getter
    drop [ alien-cell ] ;

M: string-type c-type-setter
    drop [ set-alien-cell ] ;

HOOK: alien>native-string os ( alien -- string )

HOOK: native-string>alien os ( string -- alien )

: dll-path ( dll -- string )
    path>> alien>native-string ;

: string>symbol ( str -- alien )
    dup string?
    [ native-string>alien ]
    [ [ native-string>alien ] map ] if ;

{ "char*" utf8 } "char*" typedef
"char*" "uchar*" typedef

{
    { [ os windows? ] [ "alien.strings.windows" require ] }
    { [ os unix? ] [ "alien.strings.unix" require ] }
} cond
