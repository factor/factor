! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io kernel math random ;

IN: io.random

<PRIVATE

: ?replace ( old new n -- old/new )
    random zero? [ nip ] [ drop ] if ;

PRIVATE>

: random-line ( -- line/f )
    f 1 [ swap [ ?replace ] [ 1 + ] bi ] each-line drop ;
