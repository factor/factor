! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces kernel
http.server
http.server.sessions
http.server.auth.providers ;
IN: http.server.auth

SYMBOL: logged-in-user
SYMBOL: user-profile-changed?

GENERIC: init-user-profile ( responder -- )

M: object init-user-profile drop ;

M: dispatcher init-user-profile
    default>> init-user-profile ;

M: filter-responder init-user-profile
    responder>> init-user-profile ;

: uid ( -- string ) logged-in-user sget username>> ;

: profile ( -- assoc ) logged-in-user sget profile>> ;

: uget ( key -- value )
    profile at ;

: uset ( value key -- )
    profile set-at user-profile-changed? on ;

: uchange ( quot key -- )
    profile swap change-at
    user-profile-changed? on ; inline
