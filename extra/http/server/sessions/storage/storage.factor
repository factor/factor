! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar ;
IN: http.server.sessions.storage

: timeout 20 minutes ;

GENERIC: get-session ( id storage -- namespace )

GENERIC: update-session ( namespace id storage -- )

GENERIC: delete-session ( id storage -- )

GENERIC: new-session ( namespace storage -- id )
