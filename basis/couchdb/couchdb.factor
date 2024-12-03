! Copyright (C) 2008, 2009 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations debugger hashtables http
http.client io io.encodings.string io.encodings.utf8 json kernel
make math math.parser namespaces sequences strings urls.encoding
vectors ;
IN: couchdb

! NOTE: This code only works with the latest couchdb (0.9.*),
! because old versions didn't provide the /_uuids feature which
! this code relies on when creating new documents.

SYMBOL: couch
: with-couch ( db quot -- )
    couch swap with-variable ; inline

! errors
TUPLE: couchdb-error { data assoc } ;
C: <couchdb-error> couchdb-error

M: couchdb-error error.
    "CouchDB Error: " write data>>
    "error" over at [ print ] when*
    "reason" of [ print ] when* ;

PREDICATE: file-exists-error < couchdb-error
    data>> "error" of "file_exists" = ;

! http tools
: couch-http-request ( request -- data )
    [ http-request ] [
        dup download-failed? [
            response>> body>> json> <couchdb-error> throw
        ] [
            rethrow
        ] if
    ] recover nip ;

: couch-request ( request -- assoc )
    couch-http-request json> ;

: couch-get ( url -- assoc )
    <get-request> couch-request ;

: <json-data> ( assoc -- post-data )
    >json utf8 encode "application/json" <post-data> swap >>data ;

: couch-put ( assoc url -- assoc' )
    [ <json-data> ] dip <put-request> couch-request ;

: couch-post ( assoc url -- assoc' )
    [ <json-data> ] dip <post-request> couch-request ;

: couch-delete ( url -- assoc )
    <delete-request> couch-request ;

: response-ok ( assoc -- assoc )
    "ok" over delete-at* and t assert= ;

: response-ok* ( assoc -- )
    response-ok drop ;

! server
TUPLE: server { host string } { port integer } { uuids vector } { uuids-to-cache integer } ;

CONSTANT: default-couch-host "localhost"
CONSTANT: default-couch-port 5984
CONSTANT: default-uuids-to-cache 100

: <server> ( host port -- server )
    V{ } clone default-uuids-to-cache server boa ;

: <default-server> ( -- server )
    default-couch-host default-couch-port <server> ;

: (server-url) ( server -- )
    "https://" % [ host>> % ] [ CHAR: : , port>> number>string % ] bi CHAR: / , ; inline

: server-url ( server -- url )
    [ (server-url) ] "" make ;

: all-dbs ( server -- dbs )
    server-url "_all_dbs" append couch-get ;

: uuids-url ( server -- url )
    [ dup server-url % "_uuids?count=" % uuids-to-cache>> number>string % ] "" make ;

: uuids-get ( server -- uuids )
    uuids-url couch-get "uuids" of >vector ;

: get-uuids ( server -- server )
    dup uuids-get [ nip ] curry change-uuids ;

: ensure-uuids ( server -- server )
    dup uuids>> empty? [ get-uuids ] when ;

: next-uuid ( server -- uuid )
    ensure-uuids uuids>> pop ;

! db
TUPLE: db { server server } { name string } ;
C: <db> db

: (db-url) ( db -- )
    [ server>> server-url % ] [ name>> % ] bi CHAR: / , ; inline

: db-url ( db -- url )
    [ (db-url) ] "" make ;

: create-db ( db -- )
    f swap db-url couch-put response-ok* ;

: ensure-db ( db -- )
    '[ _ create-db ] [ file-exists-error? ] ignore-error ;

: delete-db ( db -- )
    db-url couch-delete drop ;

: db-info ( db -- info )
    db-url couch-get ;

: all-docs ( db -- docs )
    ! TODO: queries. Maybe pass in a hashtable with options
    db-url "_all_docs" append couch-get ;

: compact-db ( db -- )
    f swap db-url "_compact" append couch-post response-ok* ;

! documents
: id> ( assoc -- id ) "_id" of ;
: >id ( assoc id -- assoc ) "_id" pick set-at ;
: rev> ( assoc -- rev ) "_rev" of ;
: >rev ( assoc rev -- assoc ) "_rev" pick set-at ;
: attachments> ( assoc -- attachments ) "_attachments" of ;
: >attachments ( assoc attachments -- assoc ) "_attachments" pick set-at ;

:: copy-key ( to from to-key from-key -- )
    from-key from at
    to-key to set-at ;

: copy-id ( to from -- )
    "_id" "id" copy-key ;

: copy-rev ( to from -- )
    "_rev" "rev" copy-key ;

: id-url ( id -- url )
    couch get db-url swap url-encode-full append ;

: doc-url ( assoc -- url )
    id> id-url ;

: temp-view ( view -- results )
    couch get db-url "_temp_view" append couch-post ;

: temp-view-map ( map -- results )
    "map" associate temp-view ;

: save-doc-as ( assoc id -- )
    dupd id-url couch-put response-ok
    [ copy-id ] [ copy-rev ] 2bi ;

: save-new-doc ( assoc -- )
    couch get server>> next-uuid save-doc-as ;

: save-doc ( assoc -- )
    dup id> [ save-doc-as ] [ save-new-doc ] if* ;

: load-doc ( id -- assoc )
    id-url couch-get ;

: delete-doc ( assoc -- deletion-revision )
    [
        [ doc-url % ]
        [ "?rev=" % "_rev" of % ] bi
    ] "" make couch-delete response-ok "rev" of ;

: remove-keys ( assoc keys -- )
    swap [ delete-at ] curry each ;

: remove-couch-info ( assoc -- )
    { "_id" "_rev" "_attachments" } remove-keys ;

! : construct-attachment ( content-type data -- assoc )
!     H{ } clone "name" pick set-at "content-type" pick set-at ;
!
! : add-attachment ( assoc name attachment -- )
!     pick attachments> [ H{ } clone ] unless*
!
! : attach ( assoc name content-type data -- )
!     construct-attachment H{ } clone

! TODO:
! - startkey, limit, descending, etc.
! - loading specific revisions
! - views
! - attachments
! - bulk insert/update
! - ...?
