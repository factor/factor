! Copyright (C) 2015 Dave Carlton
! See http://factorcode.org/license.txt for BSD license
USING: accessors byte-arrays calendar checksums
checksums.internet combinators combinators.smart continuations
destructors io.sockets io.sockets.icmp io.timeouts kernel
locals pack random sequences system ;

IN: ping6

<PRIVATE

TUPLE: echo type identifier sequence data ;

: <echo> ( sequence data -- echo )
    [ 8 16 random-bits ] 2dip echo boa ;

: echo>byte-array ( echo -- byte-array )
    [
        [
            [ type>> 0 0 ] ! code checksum
            [ identifier>> ]
            [ sequence>> ] tri
        ] output>array "CCSSS" pack-be
    ] [ data>> ] bi append [
        internet checksum-bytes 2 4
    ] keep replace-slice ;

: byte-array>echo ( byte-array -- echo )
    dup internet checksum-bytes B{ 0 0 } assert=
    8 cut [
        "CCSSS" unpack-be { 0 3 4 } swap nths first3
    ] dip echo boa ;

: send-ping ( addr raw -- )
    [ 0 { } <echo> echo>byte-array ] 2dip send ;

:: recv-ping ( addr raw -- echo )
    raw receive addr = [
        20 tail byte-array>echo
    ] [
        drop addr raw recv-ping
    ] if ;

PRIVATE>

HOOK: <ping-port> os ( inet -- port )

M: object <ping-port> <raw> ;

M: macosx <ping-port> <datagram> ;

: ping6 ( host -- reply )
    <icmp> resolve-host [ icmp6? ] filter random
    f <icmp6> <ping-port>
        1 seconds over set-timeout
    [ [ send-ping ] [ recv-ping ] 2bi ] with-disposal ;

: local-ping6 ( -- reply )
    "::1" ping6 ;

: alive6? ( host -- ? )
    [ ping6 drop t ] [ 2drop f ] recover ;

