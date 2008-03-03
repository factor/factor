! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db http.server kernel new-slots accessors ;
IN: http.server.db

TUPLE: db-persistence responder db params ;

C: <db-persistence> db-persistence

M: db-persistence call-responder
    dup db>> over params>> [
        responder>> call-responder
    ] with-db ;
