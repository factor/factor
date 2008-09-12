! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math kernel slots.private sequences effects words ;
IN: locals.backend

: load-locals ( n -- )
    dup zero? [ drop ] [ swap >r 1- load-locals ] if ;

: get-local ( n -- value )
    dup zero? [ drop dup ] [ r> swap 1- get-local swap >r ] if ;

: local-value 2 slot ; inline

: set-local-value 2 set-slot ; inline

: drop-locals ( n -- )
    dup zero? [ drop ] [ r> drop 1- drop-locals ] if ;
