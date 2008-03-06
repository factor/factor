! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db http.server kernel new-slots accessors
continuations namespaces destructors ;
IN: http.server.db

TUPLE: db-persistence responder db params ;

C: <db-persistence> db-persistence

: connect-db ( db-persistence -- )
    dup db>> swap params>> make-db
    dup db set
    dup db-open
    add-always-destructor ;

M: db-persistence call-responder
    dup connect-db responder>> call-responder ;
