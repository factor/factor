! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar ;
IN: http.server.sessions.storage

GENERIC: get-session ( id storage -- session )

GENERIC: update-session ( session storage -- )

GENERIC: delete-session ( id storage -- )

GENERIC: new-session ( session storage -- )
