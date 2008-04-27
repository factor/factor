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

TUPLE: session id expires namespace changed? ;

: <session> ( id -- session )
    session new
        swap >>id ;

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

M: dispatcher init-session* default>> init-session* ;

M: filter-responder init-session* responder>> init-session* ;

TUPLE: session-manager < filter-responder sessions timeout domain ;

: <session-manager> ( responder -- responder' )
    session-manager new
        swap >>responder
        null-sessions >>sessions
        20 minutes >>timeout ;

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

: init-session ( session managed -- )
    >r session r> '[ , init-session* ] with-variable ;

: cutoff-time ( -- time )
    session-manager get timeout>> from-now timestamp>millis ;

: touch-session ( session -- )
    cutoff-time >>expires drop ;

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
TUPLE: session-saver manager session ;

C: <session-saver> session-saver

M: session-saver dispose
    [ session>> ] [ manager>> sessions>> ] bi
    over changed?>> [
        [ drop touch-session ] [ update-session ] 2bi
    ] [ 2drop ] if ;

: save-session-after ( manager session -- )
    <session-saver> add-always-destructor ;

: existing-session ( path manager session -- response )
    [ nip session set ]
    [ save-session-after ]
    [ drop responder>> ] 2tri
    call-responder ;

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
    session-id-key <cookie>
        "$session-manager" resolve-base-path >>path
        session-manager get timeout>> from-now >>expires
        session-manager get domain>> >>domain ;

: put-session-cookie ( response -- response' )
    session get id>> number>string <session-cookie> put-cookie ;

: session-form-field ( -- )
    <input
        "hidden" =type
        session-id-key =name
        session get id>> number>string =value
    input/> ;

M: session-manager call-responder* ( path responder -- response )
    [ session-form-field ] add-form-hook
    dup session-manager set
    dup request-session [ dup begin-session ] unless*
    existing-session put-session-cookie ;
