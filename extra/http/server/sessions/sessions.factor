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

! ! ! ! ! !
! WARNING: this session manager is vulnerable to XSRF attacks
! ! ! ! ! !

TUPLE: session id user-agent client-addr namespace ;

: <session> ( id -- session )
    session new
        swap >>id ;

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

TUPLE: session-manager responder sessions ;

: new-session-manager ( responder class -- responder' )
    new
        null-sessions >>sessions
        swap >>responder ; inline

SYMBOL: session-changed?

: sget ( key -- value )
    session get namespace>> at ;

: sset ( value key -- )
    session get namespace>> set-at
    session-changed? on ;

: schange ( key quot -- )
    session get namespace>> swap change-at
    session-changed? on ; inline

: sessions session-manager get sessions>> ;

: managed-responder session-manager get responder>> ;

: init-session ( session managed -- )
    >r session r> '[ , init-session* ] with-variable ;

: empty-session ( -- session )
    f <session>
        "" >>user-agent
        "" >>client-addr
        H{ } clone >>namespace ;

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
    session-changed? get
    [ session>> sessions update-session ] [ drop ] if ;

: save-session-after ( session -- )
    <session-saver> add-always-destructor ;

: call-responder/session ( path responder session -- response )
    [ save-session-after ] [ session set ] bi
    [ session-manager set ] [ responder>> call-responder ] bi ;

TUPLE: null-sessions < session-manager ;

: <null-sessions> ( responder -- manager )
    null-sessions new-session-manager ;

M: null-sessions call-responder ( path responder -- response )
    <session> call-responder/session ;

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
        session-id-key =id
        session-id-key =name
        session get id>> =value
    input/> ;

: new-url-session ( path responder -- response )
    [ drop f ] [ begin-session id>> session-id-key associate ] bi*
    <temporary-redirect> ;

M: url-sessions call-responder ( path responder -- response )
    [ add-session-id ] link-hook set
    [ session-form-field ] form-hook set
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
