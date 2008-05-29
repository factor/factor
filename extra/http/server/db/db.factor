! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db db.pools io.pools http.server http.server.sessions
kernel accessors continuations namespaces destructors ;
IN: http.server.db

TUPLE: db-persistence < filter-responder pool ;

: <db-persistence> ( responder params db -- responder' )
    <db-pool> db-persistence boa ;

M: db-persistence call-responder*
    [
        pool>> [ acquire-connection ] keep
        [ return-connection-later ] [ drop db set ] 2bi
    ]
    [ call-next-method ] bi ;
