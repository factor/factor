! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: boxes kernel threads ;
IN: concurrency.flags

TUPLE: flag value? thread ;

: <flag> ( -- flag ) f <box> flag boa ;

: raise-flag ( flag -- )
    dup flag-value? [
        t over set-flag-value?
        dup flag-thread [ resume ] if-box?
    ] unless drop ;

: wait-for-flag ( flag -- )
    dup flag-value? [ drop ] [
        [ flag-thread >box ] curry "flag" suspend drop
    ] if ;

: lower-flag ( flag -- )
    dup wait-for-flag f swap set-flag-value? ;
