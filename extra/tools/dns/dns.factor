! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: dns io kernel math.parser sequences ;
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
    [ write " mail is handled by " write ]
    [ first2 [ number>string write bl ] [ print ] bi* ] bi* ;

: mx-message. ( message -- )
    [ message>query-name ] [ message>mxs ] bi
    [ mx-line. ] with each ;

: host ( domain -- )
    [ dns-A-query a-message. ]
    [ dns-AAAA-query aaaa-message. ]
    [ dns-MX-query mx-message. ] tri ;
