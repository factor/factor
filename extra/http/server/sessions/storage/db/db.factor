! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors http.server.sessions.storage
alarms kernel http.server db.tuples db.types math.parser
classes.singleton ;
IN: http.server.sessions.storage.db

SINGLETON: sessions-in-db

TUPLE: session id namespace ;

session "SESSIONS"
{
    { "id" "ID" INTEGER +native-id+ }
    { "namespace" "NAMESPACE" FACTOR-BLOB }
} define-persistent

: init-sessions-table session ensure-table ;

: <session> ( id -- session )
    session new
        swap dup [ string>number ] when >>id ;

M: sessions-in-db get-session ( id storage -- namespace/f )
    drop
    dup [
        <session>
        select-tuple dup [ namespace>> ] when
    ] when ;

M: sessions-in-db update-session ( namespace id storage -- )
    drop
    <session>
        swap >>namespace
    update-tuple ;

M: sessions-in-db delete-session ( id storage -- )
    drop
    <session>
    delete-tuple ;

M: sessions-in-db new-session ( namespace storage -- id )
    drop
    f <session>
        swap >>namespace
    [ insert-tuple ] [ id>> number>string ] bi ;
