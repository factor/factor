! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs calendar kernel math.parser namespaces random
boxes alarms new-slots accessors http http.server
quotations hashtables sequences fry combinators.cleave ;
IN: http.server.sessions

! ! ! ! ! !
! WARNING: this session manager is vulnerable to XSRF attacks
! ! ! ! ! !

GENERIC: init-session* ( responder -- )

M: dispatcher init-session* drop ;

TUPLE: session-manager responder sessions ;

: <session-manager> ( responder class -- responder' )
    >r H{ } clone session-manager construct-boa r>
    construct-delegate ; inline

TUPLE: session manager id namespace alarm ;

: <session> ( manager -- session )
    f H{ } clone <box> \ session construct-boa ;

: timeout ( -- dt ) 20 minutes ;

: cancel-timeout ( session -- )
    alarm>> [ cancel-alarm ] if-box? ;

: delete-session ( session -- )
    [ cancel-timeout ]
    [ dup manager>> sessions>> delete-at ]
    bi ;

: touch-session ( session -- session )
    [ cancel-timeout ]
    [ [ '[ , delete-session ] timeout later ] keep alarm>> >box ]
    [ ]
    tri ;

: session ( -- assoc ) \ session get namespace>> ;

: sget ( key -- value ) session at ;

: sset ( value key -- ) session set-at ;

: schange ( key quot -- ) session swap change-at ; inline

: init-session ( session -- session )
    dup dup \ session [
        manager>> responder>> init-session*
    ] with-variable ;

: new-session ( responder -- id )
    [ <session> init-session touch-session ]
    [ [ sessions>> set-at-unique ] [ drop swap >>id ] 2bi ]
    bi id>> ;

: get-session ( id responder -- session/f )
    sessions>> at* [ touch-session ] when ;

: call-responder/session ( path responder session -- response )
    \ session set responder>> call-responder ;

: sessions ( -- manager/f )
    \ session get dup [ manager>> ] when ;

GENERIC: session-link* ( url query sessions -- string )

M: object session-link* 2drop url-encode ;

: session-link ( url query -- string ) sessions session-link* ;

TUPLE: null-sessions ;

: <null-sessions>
    null-sessions <session-manager> ;

M: null-sessions call-responder ( path responder -- response )
    dup <session> call-responder/session ;

TUPLE: url-sessions ;

: <url-sessions> ( responder -- responder' )
    url-sessions <session-manager> ;

: sess-id "factorsessid" ;

: current-session ( responder request -- session )
    sess-id query-param swap get-session ;

M: url-sessions call-responder ( path responder -- response )
    dup request get current-session [
        call-responder/session
    ] [
        nip
        f swap new-session sess-id associate <temporary-redirect>
    ] if* ;

M: url-sessions session-link*
    drop
    url-encode
    \ session get id>> sess-id associate union assoc>query
    dup assoc-empty? [ drop ] [ "?" swap 3append ] if ;

TUPLE: cookie-sessions ;

: <cookie-sessions> ( responder -- responder' )
    cookie-sessions <session-manager> ;

: get-session-cookie ( responder -- cookie )
    request get sess-id get-cookie
    [ value>> swap get-session ] [ drop f ] if* ;

: <session-cookie> ( id -- cookie )
    sess-id <cookie> ;

M: cookie-sessions call-responder ( path responder -- response )
    dup get-session-cookie [
        call-responder/session
    ] [
        dup new-session
        [ over get-session call-responder/session ] keep
        <session-cookie> put-cookie
    ] if* ;
