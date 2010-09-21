! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays calendar checksums
checksums.internet combinators combinators.smart continuations
destructors io.sockets io.sockets.icmp io.timeouts kernel pack
random sequences locals ;

IN: ping

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

: send-ping ( addr datagram -- )
    [ 0 { } <echo> echo>byte-array ] 2dip send ;

:: recv-ping ( addr datagram -- echo )
    datagram receive addr = [
        20 tail byte-array>echo
    ] [
        drop addr datagram recv-ping
    ] if ;

PRIVATE>

: ping ( host -- reply )
    <icmp> resolve-host [ icmp4? ] filter random
    f <icmp4> <datagram>
        1 seconds over set-timeout
    [ [ send-ping ] [ recv-ping ] 2bi ] with-disposal ;

: local-ping ( -- reply )
    "127.0.0.1" ping ;

: alive? ( host -- ? )
    [ ping drop t ] [ 2drop f ] recover ;

