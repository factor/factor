! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math.parser namespaces random
accessors quotations hashtables sequences continuations
fry calendar combinators destructors
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

M: filter-responder init-session* responder>> init-session* ;

TUPLE: session-manager < filter-responder sessions ;

: <session-manager> ( responder -- responder' )
    null-sessions session-manager boa ;

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
    [ init-session ]
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

: existing-session ( path responder session -- response )
    [ session set ] [ save-session-after ] bi
    [ session-manager set ] [ responder>> call-responder ] bi ;

: session-id-key "factorsessid" ;

: cookie-session-id ( -- id/f )
    request get session-id-key get-cookie
    dup [ value>> string>number ] when ;

: post-session-id ( -- id/f )
    session-id-key request get post-data>> at string>number ;

: request-session-id ( -- id/f )
    request get method>> {
        { "GET" [ cookie-session-id ] }
        { "HEAD" [ cookie-session-id ] }
        { "POST" [ post-session-id ] }
    } case ;

: request-session ( responder -- session/f )
    >r request-session-id r> sessions>> get-session ;

: <session-cookie> ( id -- cookie )
    session-id-key <cookie> ;

: new-session ( path responder -- response )
    dup begin-session
    [ existing-session ]
    [ id>> number>string <session-cookie> ] bi
    put-cookie ;

: session-form-field ( -- )
    <input
        "hidden" =type
        session-id-key =name
        session get id>> number>string =value
    input/> ;

M: session-manager call-responder ( path responder -- response )
    [ session-form-field ] add-form-hook
    dup request-session [ existing-session ] [ new-session ] if* ;
