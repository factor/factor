! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: boxes kernel threads ;
IN: concurrency.flags

TUPLE: flag value? thread ;

: <flag> ( -- flag ) f <box> flag construct-boa ;

: raise-flag ( flag -- )
    dup flag-value? [
        dup flag-thread ?box
        [ resume ] [ drop t over set-flag-value? ] if
    ] unless drop ;

: lower-flag ( flag -- )
    dup flag-value? [
        f swap set-flag-value?
    ] [
        [ flag-thread >box ] curry "flag" suspend drop
    ] if ;
