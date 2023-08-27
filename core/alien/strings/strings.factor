! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays byte-vectors io
io.encodings io.encodings.ascii io.encodings.utf16
io.encodings.utf8 io.streams.memory kernel kernel.private math
namespaces sequences sequences.private strings strings.private
system system.private ;
IN: alien.strings

GENERIC#: alien>string 1 ( c-ptr encoding -- string/f )

M: c-ptr alien>string
    [ <memory-stream> ] [ <decoder> ] bi*
    "\0" swap stream-read-until drop ;

M: object alien>string
    [ underlying>> ] dip alien>string ;

M: f alien>string
    drop ;

ERROR: invalid-c-string string ;

: check-c-string ( string -- )
    0 over member-eq? [ invalid-c-string ] [ drop ] if ;

GENERIC#: string>alien 1 ( string encoding -- byte-array )

M: c-ptr string>alien drop ;

<PRIVATE

: fast-string? ( string encoding -- ? )
    swap aux>> not [ { ascii utf8 } member-eq? ] [ drop f ] if ; inline

: string>alien-fast ( string encoding -- byte-array )
    { string object } declare ! aux>> must be f
    drop [ length ] keep over [
        1 + (byte-array) [
            [
                [ [ string-nth-fast ] keepd ]
                [ set-nth-unsafe ] bi*
            ] 2curry each-integer
        ] keep
    ] keep 0 swap pick set-nth-unsafe ;

: string>alien-slow ( string encoding -- byte-array )
    { string object } declare
    over length 1 + over guess-encoded-length <byte-vector> [
        swap <encoder> [ stream-write ] [ 0 swap stream-write1 ] bi
    ] keep B{ } like ;

PRIVATE>

M: string string>alien
    over check-c-string
    2dup fast-string?
    [ string>alien-fast ]
    [ string>alien-slow ] if ;

M: tuple string>alien drop underlying>> ;

HOOK: native-string-encoding os ( -- encoding ) foldable

M: unix native-string-encoding utf8 ;

M: windows native-string-encoding utf16n ;

: alien>native-string ( alien -- string )
    native-string-encoding alien>string ; inline

: native-string>alien ( string -- alien )
    native-string-encoding string>alien ; inline

: dll-path ( dll -- string )
    path>> alien>native-string ;

GENERIC: string>symbol ( str/seq -- alien )

M: string string>symbol utf8 string>alien ;

M: sequence string>symbol [ utf8 string>alien ] map ;

GENERIC: symbol>string ( symbol(s) -- string )

M: byte-array symbol>string utf8 alien>string ;

M: array symbol>string [ utf8 alien>string ] map ", " join ;

: special-object>string ( n -- str )
    special-object utf8 alien>string ;

STARTUP-HOOK: [
    OBJ-CPU special-object>string string>cpu \ cpu set-global
    OBJ-OS special-object>string string>os \ os set-global
    OBJ-VM-VERSION special-object>string \ vm-version set-global
    OBJ-VM-GIT-LABEL special-object>string \ vm-git-label set-global
    OBJ-VM-COMPILER special-object>string \ vm-compiler set-global
    OBJ-VM-COMPILE-TIME special-object>string \ vm-compile-time set-global
]
