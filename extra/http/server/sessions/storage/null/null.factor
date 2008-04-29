! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel http.server.sessions.storage ;
IN: http.server.sessions.storage.null

SINGLETON: null-sessions

: null-sessions-error "No session storage installed" throw ;

M: null-sessions get-session null-sessions-error ;

M: null-sessions update-session null-sessions-error ;

M: null-sessions delete-session null-sessions-error ;

M: null-sessions new-session null-sessions-error ;
