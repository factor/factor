! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays byte-vectors init io
io.encodings io.encodings.ascii io.encodings.utf16n
io.encodings.utf8 io.streams.memory kernel kernel.private math
namespaces sequences sequences.private strings strings.private
system system.private ;
IN: alien.strings

GENERIC# alien>string 1 ( c-ptr encoding -- string/f )

M: c-ptr alien>string
    [ <memory-stream> ] [ <decoder> ] bi*
    "\0" swap stream-read-until drop ;

M: object alien>string
    [ underlying>> ] dip alien>string ;

M: f alien>string
    drop ;

ERROR: invalid-c-string string ;

: check-string ( string -- )
    0 over member-eq? [ invalid-c-string ] [ drop ] if ;

GENERIC# string>alien 1 ( string encoding -- byte-array )

M: c-ptr string>alien drop ;

<PRIVATE

: fast-string? ( string encoding -- ? )
    [ aux>> not ] [ { ascii utf8 } member-eq? ] bi* and ; inline

: string>alien-fast ( string encoding -- byte-array )
    { string object } declare ! aux>> must be f
    drop [ length ] keep over [
        1 + (byte-array) [
            [
                [ [ string-nth-fast ] 2keep drop ]
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
    over check-string
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

: (symbol>string) ( alien -- str )
    utf8 alien>string ;

GENERIC: symbol>string ( symbol(s) -- string )
M: byte-array symbol>string (symbol>string) ;
M: array symbol>string [ (symbol>string) ] map ", " join ;

[
    OBJ-CPU special-object utf8 alien>string string>cpu \ cpu set-global
    OBJ-OS special-object utf8 alien>string string>os \ os set-global
    OBJ-VM-COMPILER special-object utf8 alien>string \ vm-compiler set-global
] "alien.strings" add-startup-hook
