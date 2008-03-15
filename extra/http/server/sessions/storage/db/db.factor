! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs new-slots accessors http.server.sessions.storage
alarms kernel http.server db.tuples db.types singleton
combinators.cleave math.parser ;
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
    session construct-empty
        swap dup [ string>number ] when >>id ;

USING: namespaces io prettyprint ;
M: sessions-in-db get-session ( id storage -- namespace/f )
    global [ "get " write over print flush ] bind
    drop
    dup [
        <session>
        select-tuple dup [ namespace>> ] when global [ dup . ] bind
    ] when ;

M: sessions-in-db update-session ( namespace id storage -- )
    global [ "update " write over print flush ] bind
    drop
    <session>
        swap  global [ dup . ] bind >>namespace
    dup update-tuple
    id>> <session> select-tuple global [ . flush ] bind
    ;

M: sessions-in-db delete-session ( id storage -- )
    drop
    <session>
    delete-tuple ;

M: sessions-in-db new-session ( namespace storage -- id )
    global [ "new " print flush ] bind
    drop
    f <session>
        swap  global [ dup . ] bind >>namespace
    [ insert-tuple ] [ id>> number>string ] bi ;
