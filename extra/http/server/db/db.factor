! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db http.server kernel new-slots accessors
continuations namespaces ;
IN: http.server.db

TUPLE: db-persistence responder db params ;

C: <db-persistence> db-persistence

M: db-persistence call-responder
    dup db>> over params>> make-db dup db-open [
        db set responder>> call-responder
    ] with-disposal ;
