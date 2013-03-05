! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays byte-arrays init io io.encodings
io.encodings.utf16n io.encodings.utf8 io.streams.byte-array
io.streams.memory kernel kernel.private namespaces sequences
strings system system.private ;
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

M: string string>alien
    over check-string
    <byte-writer>
    [ stream-write ]
    [ 0 swap stream-write1 ]
    [ stream>> >byte-array ]
    tri ;

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

GENERIC: symbol>string ( symbol(s) -- string(s) )
M: byte-array symbol>string (symbol>string) ;
M: array symbol>string [ (symbol>string) ] map ;

[
    OBJ-CPU special-object utf8 alien>string string>cpu \ cpu set-global
    OBJ-OS special-object utf8 alien>string string>os \ os set-global
    OBJ-VM-COMPILER special-object utf8 alien>string \ vm-compiler set-global
] "alien.strings" add-startup-hook
