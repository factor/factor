! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors kernel http.server.sessions.storage
http.server.sessions http.server db.tuples db.types math.parser
classes.singleton random ;
IN: http.server.sessions.storage.db

SINGLETON: sessions-in-db

session "SESSIONS"
{
    ! { "id" "ID" +random-id+ system-random-generator }
    { "id" "ID" INTEGER +native-id+ }
    { "user-agent" "USERAGENT" { VARCHAR 256 } +not-null+ }
    { "client-addr" "CLIENTADDR" { VARCHAR 256 } +not-null+ }
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
