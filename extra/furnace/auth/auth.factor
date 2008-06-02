! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces kernel sequences sets
http.server
http.server.filters
http.server.dispatchers
furnace.sessions
furnace.auth.providers ;
IN: furnace.auth

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

SYMBOL: capabilities

V{ } clone capabilities set-global

: define-capability ( word -- ) capabilities get adjoin ;
