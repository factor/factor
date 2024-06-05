! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit db.tuples db.types
furnace.cache furnace.scopes furnace.utilities http http.server
http.server.dispatchers http.server.filters io.sockets kernel
math.parser namespaces strings ;
IN: furnace.sessions

TUPLE: session < scope user-agent client ;

: <session> ( id -- session )
    session new-server-state ;

session "SESSIONS"
{
    { "user-agent" "USER_AGENT" TEXT +not-null+ }
    { "client" "CLIENT" TEXT +not-null+ }
} define-persistent

: get-session ( id -- session )
    dup [ session get-state ] when ;

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

M: dispatcher init-session* default>> init-session* ;

M: filter-responder init-session* responder>> init-session* ;

TUPLE: sessions < server-state-manager domain verify? ;

: <sessions> ( responder -- responder' )
    sessions new-server-state-manager
        t >>verify? ;

: session-changed ( -- )
    session get scope-changed ;

: sget ( key -- value ) session get scope-get ;

: sset ( value key -- ) session get scope-set ;

: schange ( key quot -- ) session get scope-change ; inline

: init-session ( session -- )
    session [ sessions get init-session* ] with-variable ;

: touch-session ( session -- )
    sessions get touch-state ;

: remote-host ( -- string )
    {
        [ request get "x-forwarded-for" header ]
        [ remote-address get host>> ]
    } 0|| ;

: empty-session ( -- session )
    session empty-scope
        remote-host >>client
        user-agent >>user-agent
        dup touch-session ;

: begin-session ( -- session )
    empty-session [ init-session ] [ insert-tuple ] [ ] tri ;

: save-session-after ( session -- )
    sessions get save-scope-after ;

: existing-session ( path session -- response )
    [ session set ] [ save-session-after ] bi
    sessions get responder>> call-responder ;

CONSTANT: session-id-key "__s"

: verify-session ( session -- session )
    sessions get verify?>> [
        dup [
            dup
            [ client>> remote-host = ]
            [ user-agent>> user-agent = ]
            bi and and*
        ] when
    ] when ;

: request-session ( -- session/f )
    session-id-key
    client-state dup string? [ string>number ] when
    get-session verify-session ;

: <session-cookie> ( -- cookie )
    session get id>> session-id-key <cookie>
        "$sessions" resolve-base-path >>path
        sessions get domain>> >>domain ;

: put-session-cookie ( response -- response' )
    <session-cookie> put-cookie ;

M: sessions modify-form
    drop session get id>> session-id-key hidden-form-field ;

M: sessions call-responder*
    sessions set
    request-session [ begin-session ] unless*
    existing-session put-session-cookie ;

SLOT: session

: check-session ( state/f -- state/f )
    dup [ dup session>> session get id>> = and* ] when ;
