! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math.parser namespaces random
accessors quotations hashtables sequences continuations
fry calendar destructors
http
http.server
http.server.sessions.storage
http.server.sessions.storage.null
html.elements ;
IN: http.server.sessions

TUPLE: session id expiry namespace changed? ;

: <session> ( id -- session )
    session new
        swap >>id ;

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

M: dispatcher init-session* default>> init-session* ;

TUPLE: session-manager responder sessions ;

: new-session-manager ( responder class -- responder' )
    new
        null-sessions >>sessions
        swap >>responder ; inline

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

: sessions session-manager get sessions>> ;

: managed-responder session-manager get responder>> ;

: init-session ( session managed -- )
    >r session r> '[ , init-session* ] with-variable ;

: timeout 20 minutes ;

: cutoff-time ( -- time )
    now timeout time+ timestamp>millis ;

: touch-session ( session -- )
    cutoff-time >>expiry drop ;

: empty-session ( -- session )
    f <session>
        H{ } clone >>namespace
        dup touch-session ;

: begin-session ( responder -- session )
    >r empty-session r>
    [ responder>> init-session ]
    [ sessions>> new-session ]
    [ drop ]
    2tri ;

! Destructor
TUPLE: session-saver session ;

C: <session-saver> session-saver

M: session-saver dispose
    session>> dup changed?>> [
        [ touch-session ] [ sessions update-session ] bi
    ] [ drop ] if ;

: save-session-after ( session -- )
    <session-saver> add-always-destructor ;

: call-responder/session ( path responder session -- response )
    [ save-session-after ] [ session set ] bi
    [ session-manager set ] [ responder>> call-responder ] bi ;

TUPLE: url-sessions < session-manager ;

: <url-sessions> ( responder -- responder' )
    url-sessions new-session-manager ;

: session-id-key "factorsessid" ;

: current-url-session ( responder -- session/f )
    >r request-params session-id-key swap at string>number
    r> sessions>> get-session ;

: add-session-id ( query -- query' )
    session get [ id>> session-id-key associate assoc-union ] when* ;

: session-form-field ( -- )
    <input
        "hidden" =type
        session-id-key =name
        session get id>> number>string =value
    input/> ;

: new-url-session ( path responder -- response )
    [ drop f ] [ begin-session id>> session-id-key associate ] bi*
    <temporary-redirect> ;

M: url-sessions call-responder ( path responder -- response )
    [ add-session-id ] add-link-hook
    [ session-form-field ] add-form-hook
    dup current-url-session [
        call-responder/session
    ] [
        new-url-session
    ] if* ;

TUPLE: cookie-sessions < session-manager ;

: <cookie-sessions> ( responder -- responder' )
    cookie-sessions new-session-manager ;

: current-cookie-session ( responder -- session/f )
    request get session-id-key get-cookie dup
    [ value>> string>number swap sessions>> get-session ]
    [ 2drop f ] if ;

: <session-cookie> ( id -- cookie )
    session-id-key <cookie> ;

: call-responder/new-session ( path responder -- response )
    dup begin-session
    [ call-responder/session ]
    [ id>> number>string <session-cookie> ] bi
    put-cookie ;

M: cookie-sessions call-responder ( path responder -- response )
    dup current-cookie-session [
        call-responder/session
    ] [
        call-responder/new-session
    ] if* ;
