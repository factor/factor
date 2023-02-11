! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: slots.private ;
IN: locals.backend

PRIMITIVE: drop-locals ( n -- )
PRIMITIVE: get-local ( n -- obj )
PRIMITIVE: load-local ( obj -- )
PRIMITIVE: load-locals ( ... n -- )

: local-value ( box -- value ) 2 slot ; inline

: set-local-value ( value box -- ) 2 set-slot ; inline
