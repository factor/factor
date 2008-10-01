! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations debugger http.client io json.reader json.writer kernel sequences strings ;
IN: couchdb

TUPLE: server { base string initial: "http://localhost:5984" } ;

TUPLE: db { server server } { name string } ;

: db-path ( db -- path )
    [ server>> base>> ] [ name>> ] bi "/" swap 3array concat ;

TUPLE: couchdb-error { data assoc } ;
C: <couchdb-error> couchdb-error

M: couchdb-error error. ( error -- )
    "CouchDB Error: " write data>>
    "error" over at [ print ] when*
    "reason" swap at [ print ] when* ;

PREDICATE: db-exists-error < couchdb-error
    data>> "error" swap at [
        "database_already_exists" =
    ] [ f ] if* ;

: check-request ( response-data success? -- )
    [ drop ] [ <couchdb-error> throw ] if ;

: couchdb-put ( request-data url -- json-response success? )
    <put-request> (http-request) json> swap code>> success? ;

USE: prettyprint 

: (create-db) ( db -- db json success? )
    f over db-path couchdb-put ;

: create-db ( db -- db )
    (create-db) check-request ;

: ensure-db ( db -- db )
    (create-db) [ drop ] [
        <couchdb-error> dup db-exists-error? [ drop ] [ throw ] if
    ] if ;
