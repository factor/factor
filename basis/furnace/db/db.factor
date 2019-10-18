! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors continuations namespaces destructors
db db.private db.pools io.pools http.server http.server.filters ;
IN: furnace.db

TUPLE: db-persistence < filter-responder pool ;

: <db-persistence> ( responder db -- responder' )
    <db-pool> db-persistence boa ;

M: db-persistence call-responder*
    [
        pool>> [ acquire-connection ] keep
        [ return-connection-later ] [ drop db-connection set ] 2bi
    ]
    [ call-next-method ] bi ;
