! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.private kernel slots.private sequences effects words ;
IN: locals.backend

: load-locals ( n -- )
    dup 0 eq? [ drop ] [ swap >r 1 fixnum-fast load-locals ] if ;

: local-value 2 slot ; inline

: set-local-value 2 set-slot ; inline
