! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.data alien.syntax combinators core-foundation
formatting io.binary kernel math ;

IN: gestalt

<PRIVATE

TYPEDEF: SInt16 OSErr

TYPEDEF: UInt32 OSType

FUNCTION: OSErr Gestalt ( OSType selector, SInt32* response ) ;

PRIVATE>

: gestalt ( selector -- response )
    0 SInt32 <ref> [ Gestalt ] keep
    swap [ throw ] unless-zero le> ;

: system-version ( -- n )
    "sysv" be> gestalt ;

: system-version-major ( -- n )
    "sys1" be> gestalt ;

: system-version-minor ( -- n )
    "sys2" be> gestalt ;

: system-version-bugfix ( -- n )
    "sys3" be> gestalt ;

: system-version-string ( -- str )
    system-version-major
    system-version-minor
    system-version-bugfix
    "%s.%s.%s" sprintf ;

: system-code-name ( -- str )
    system-version HEX: FFF0 bitand {
        { HEX: 1070 [ "Lion"         ] }
        { HEX: 1060 [ "Snow Leopard" ] }
        { HEX: 1050 [ "Leopard"      ] }
        { HEX: 1040 [ "Tiger"        ] }
        { HEX: 1030 [ "Panther"      ] }
        { HEX: 1020 [ "Jaguar"       ] }
        { HEX: 1010 [ "Puma"         ] }
        { HEX: 1000 [ "Cheetah"      ] }
        [ drop "Unknown" ]
    } case ;

