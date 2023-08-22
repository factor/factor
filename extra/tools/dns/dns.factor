! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays command-line dns fry io kernel math.parser
namespaces sequences strings ;
IN: tools.dns

: a-line. ( host ip -- )
    [ write " has address " write ] [ print ] bi* ;

: aaaa-line. ( host ip -- )
    [ write " has IPv6 address " write ] [ print ] bi* ;

: a-message. ( message -- )
    [ message>query-name ] [ message>a-names ] bi
    [ a-line. ] with each ;

: (aaaa-message.) ( message -- )
    [ message>query-name ] [ message>aaaa-names ] bi
    [ aaaa-line. ] with each ;

: aaaa-message. ( message -- )
    [ a-message. ] [ (aaaa-message.) ] bi ;

: mx-line. ( host pair -- )
    dup length 1 = [
        [ write " is an alias for " write ]
        [ first print ] bi*
    ] [
        [ write " mail is handled by " write ]
        [ first2 [ number>string write bl ] [ print ] bi* ] bi*
    ] if ;

: mx-message. ( message -- )
    [ message>query-name ] [ message>mxs ] bi
    [ mx-line. ] with each ;

: host ( domain -- )
    [ dns-A-query a-message. ]
    [ dns-AAAA-query aaaa-message. ]
    [ dns-MX-query mx-message. ] tri ;

GENERIC#: dns-host 1 ( servers domain -- )

M: sequence dns-host ( servers domain -- )
    '[ _ host ] with-dns-servers ;

M: string dns-host
    [ 1array ] dip dns-host ;

: run-host ( -- )
    command-line get first host ;

MAIN: run-host
