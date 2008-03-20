! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs calendar kernel math.parser namespaces random
accessors http http.server
http.server.sessions.storage http.server.sessions.storage.assoc
quotations hashtables sequences fry combinators.cleave
html.elements symbols continuations destructors ;
IN: http.server.sessions

! ! ! ! ! !
! WARNING: this session manager is vulnerable to XSRF attacks
! ! ! ! ! !

GENERIC: init-session* ( responder -- )

M: object init-session* drop ;

TUPLE: session-manager responder sessions ;

: <session-manager> ( responder class -- responder' )
    >r <sessions-in-memory> session-manager construct-boa
    r> construct-delegate ; inline

SYMBOLS: session session-id session-changed? ;

: sget ( key -- value )
    session get at ;

: sset ( value key -- )
    session get set-at
    session-changed? on ;

: schange ( key quot -- )
    session get swap change-at
    session-changed? on ; inline

: sessions session-manager get sessions>> ;

: managed-responder session-manager get responder>> ;

: init-session ( managed -- session )
    H{ } clone [ session [ init-session* ] with-variable ] keep ;

: begin-session ( responder -- id session )
    [ responder>> init-session ] [ sessions>> ] bi
    [ new-session ] [ drop ] 2bi ;

! Destructor
TUPLE: session-saver id session ;

C: <session-saver> session-saver

M: session-saver dispose
    session-changed? get [
        [ session>> ] [ id>> ] bi
        sessions update-session
    ] [ drop ] if ;

: save-session-after ( id session -- )
    <session-saver> add-always-destructor ;

: call-responder/session ( path responder id session -- response )
    [ save-session-after ]
    [ [ session-id set ] [ session set ] bi* ] 2bi
    [ session-manager set ] [ responder>> call-responder ] bi ;

TUPLE: null-sessions ;

: <null-sessions>
    null-sessions <session-manager> ;

M: null-sessions call-responder ( path responder -- response )
    H{ } clone f call-responder/session ;

TUPLE: url-sessions ;

: <url-sessions> ( responder -- responder' )
    url-sessions <session-manager> ;

: session-id-key "factorsessid" ;

: current-url-session ( responder -- id/f session/f )
    [ request-params session-id-key swap at ] [ sessions>> ] bi*
    [ drop ] [ get-session ] 2bi ;

: add-session-id ( query -- query' )
    session-id get [ session-id-key associate union ] when* ;

: session-form-field ( -- )
    <input
        "hidden" =type
        session-id-key =id
        session-id-key =name
        session-id get =value
    input/> ;

: new-url-session ( responder -- response )
    [ f ] [ begin-session drop session-id-key associate ] bi*
    <temporary-redirect> ;

M: url-sessions call-responder ( path responder -- response )
    [ add-session-id ] link-hook set
    [ session-form-field ] form-hook set
    dup current-url-session dup [
        call-responder/session
    ] [
        2drop nip new-url-session
    ] if ;

TUPLE: cookie-sessions ;

: <cookie-sessions> ( responder -- responder' )
    cookie-sessions <session-manager> ;

: current-cookie-session ( responder -- id namespace/f )
    request get session-id-key get-cookie dup
    [ value>> dup rot sessions>> get-session ] [ 2drop f f ] if ;

: <session-cookie> ( id -- cookie )
    session-id-key <cookie> ;

: call-responder/new-session ( path responder -- response )
    dup begin-session
    [ call-responder/session ]
    [ drop <session-cookie> ] 2bi
    put-cookie ;

M: cookie-sessions call-responder ( path responder -- response )
    dup current-cookie-session dup [
        call-responder/session
    ] [
        2drop call-responder/new-session
    ] if ;
