! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math.intervals math.parser namespaces
strings random accessors quotations hashtables sequences continuations
fry calendar combinators combinators.lib destructors alarms
io.servers.connection
db db.tuples db.types
http http.server http.server.dispatchers http.server.filters
html.elements
furnace furnace.cache combinators.short-circuit ;
IN: furnace.sessions

TUPLE: session < server-state namespace user-agent client changed? ;

: <session> ( id -- session )
    session new-server-state ;

session "SESSIONS"
{
    { "namespace" "NAMESPACE" FACTOR-BLOB +not-null+ }
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

: (session-changed) ( session -- )
    t >>changed? drop ;

: session-changed ( -- )
    session get (session-changed) ;

: sget ( key -- value )
    session get namespace>> at ;

: sset ( value key -- )
    session get
    [ namespace>> set-at ] [ (session-changed) ] bi ;

: schange ( key quot -- )
    session get
    [ namespace>> swap change-at ] keep
    (session-changed) ; inline

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
    f <session>
        H{ } clone >>namespace
        remote-host >>client
        user-agent >>user-agent
        dup touch-session ;

: begin-session ( -- session )
    empty-session [ init-session ] [ insert-tuple ] [ ] tri ;

! Destructor
TUPLE: session-saver session ;

C: <session-saver> session-saver

M: session-saver dispose
    session>> dup changed?>> [
        [ touch-session ] [ update-tuple ] bi
    ] [ drop ] if ;

: save-session-after ( session -- )
    <session-saver> &dispose drop ;

: existing-session ( path session -- response )
    [ session set ] [ save-session-after ] bi
    sessions get responder>> call-responder ;

: session-id-key "__s" ;

: verify-session ( session -- session )
    sessions get verify?>> [
        dup [
            dup
            [ client>> remote-host = ]
            [ user-agent>> user-agent = ]
            bi and [ drop f ] unless
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

M: sessions modify-form ( responder -- )
    drop session get id>> session-id-key hidden-form-field ;

M: sessions call-responder* ( path responder -- response )
    sessions set
    request-session [ begin-session ] unless*
    existing-session put-session-cookie ;
