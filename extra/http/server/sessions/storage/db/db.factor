! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors kernel http.server.sessions.storage
http.server.sessions http.server db db.tuples db.types math.parser
math.intervals fry random calendar sequences alarms ;
IN: http.server.sessions.storage.db

SINGLETON: sessions-in-db

session "SESSIONS"
{
    ! { "id" "ID" +random-id+ system-random-generator }
    { "id" "ID" INTEGER +native-id+ }
    { "expiry" "EXPIRY" BIG-INTEGER +not-null+ }
    { "namespace" "NAMESPACE" FACTOR-BLOB }
} define-persistent

: init-sessions-table session ensure-table ;

M: sessions-in-db get-session ( id storage -- session/f )
    drop dup [ <session> select-tuple ] when ;

M: sessions-in-db update-session ( session storage -- )
    drop update-tuple ;

M: sessions-in-db delete-session ( id storage -- )
    drop <session> delete-tuple ;

M: sessions-in-db new-session ( session storage -- )
    drop insert-tuple ;

: expired-sessions ( -- session )
    f <session>
    USE: math now timestamp>millis [ 60 60 * 1000 * - ] keep [a,b] >>expiry
    select-tuples ;

: start-expiring-sessions ( db seq -- )
    '[
        , , [ expired-sessions [ delete-tuple ] each ] with-db
    ] 5 minutes every drop ;
