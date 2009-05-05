! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel kernel.private accessors math
alien.accessors byte-arrays io io.encodings io.encodings.utf8
io.encodings.utf16n io.streams.byte-array io.streams.memory system
system.private alien strings combinators namespaces init ;
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

HOOK: alien>native-string os ( alien -- string )

M: windows alien>native-string utf16n alien>string ;

M: unix alien>native-string utf8 alien>string ;

HOOK: native-string>alien os ( string -- alien )

M: wince native-string>alien utf16n string>alien ;

M: winnt native-string>alien utf8 string>alien ;

M: unix native-string>alien utf8 string>alien ;

: dll-path ( dll -- string )
    path>> alien>native-string ;

: string>symbol ( str -- alien )
    dup string?
    [ native-string>alien ]
    [ [ native-string>alien ] map ] if ;

[
    8 getenv utf8 alien>string string>cpu \ cpu set-global
    9 getenv utf8 alien>string string>os \ os set-global
] "alien.strings" add-init-hook

