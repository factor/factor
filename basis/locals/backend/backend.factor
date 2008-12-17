! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slots.private ;
IN: locals.backend

: local-value ( box -- value ) 2 slot ; inline

: set-local-value ( value box -- ) 2 set-slot ; inline
