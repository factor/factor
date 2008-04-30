! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces kernel
http.server
http.server.sessions
http.server.auth.providers ;
IN: http.server.auth

SYMBOL: logged-in-user

GENERIC: init-user-profile ( responder -- )

M: object init-user-profile drop ;

M: dispatcher init-user-profile
    default>> init-user-profile ;

M: filter-responder init-user-profile
    responder>> init-user-profile ;

: profile ( -- assoc ) logged-in-user get profile>> ;

: user-changed ( -- )
    logged-in-user get t >>changed? drop ;

: uget ( key -- value )
    profile at ;

: uset ( value key -- )
    profile set-at
    user-changed ;

: uchange ( quot key -- )
    profile swap change-at
    user-changed ; inline
