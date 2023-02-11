! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.conditions dlists kernel ;
IN: concurrency.flags

TUPLE: flag value threads ;

: <flag> ( -- flag ) f <dlist> flag boa ;

: raise-flag ( flag -- )
    dup value>> [ drop ] [ t >>value threads>> notify-all ] if ;

: wait-for-flag-timeout ( flag timeout -- )
    over value>> [ 2drop ] [ [ threads>> ] dip "flag" wait ] if ;

: wait-for-flag ( flag -- )
    f wait-for-flag-timeout ;

: lower-flag ( flag -- )
    [ wait-for-flag ] [ f >>value drop ] bi ;
