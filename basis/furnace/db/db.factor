! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db db.pools destructors http.server
http.server.filters io.pools kernel namespaces ;
IN: furnace.db

TUPLE: db-persistence < filter-responder pool disposed ;

: <db-persistence> ( responder db -- responder' )
    <db-pool> f db-persistence boa ;

M: db-persistence call-responder*
    [
        pool>> [ acquire-connection ] keep
        [ return-connection-later ] [ drop db-connection set ] 2bi
    ]
    [ call-next-method ] bi ;

M: db-persistence dispose* pool>> dispose ;
