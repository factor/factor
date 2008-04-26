! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db http.server http.server.sessions kernel accessors
continuations namespaces destructors ;
IN: http.server.db

TUPLE: db-persistence < filter-responder db params ;

C: <db-persistence> db-persistence

: connect-db ( db-persistence -- )
    [ db>> ] [ params>> ] bi make-db db-open
    [ db set ] [ add-always-destructor ] bi ;

M: db-persistence call-responder
    [ connect-db ] [ call-next-method ] bi ;
