! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs calendar kernel math.parser namespaces random
boxes alarms new-slots accessors http http.server
quotations hashtables sequences ;
IN: http.server.sessions

! ! ! ! ! !
! WARNING: this session manager is vulnerable to XSRF attacks
! ! ! ! ! !

GENERIC: init-session ( responder -- )

TUPLE: session-manager responder sessions ;

: <session-manager> ( responder class -- responder' )
    >r H{ } clone session-manager construct-boa r>
    construct-delegate ; inline

TUPLE: session id manager namespace alarm ;

: <session> ( id manager -- session )
    H{ } clone <box> \ session construct-boa ;

: timeout ( -- dt ) 20 minutes ;

: cancel-timeout ( session -- )
    alarm>> [ cancel-alarm ] if-box? ;

: delete-session ( session -- )
    dup cancel-timeout
    dup manager>> sessions>> delete-at ;

: touch-session ( session -- )
    dup cancel-timeout
    dup [ delete-session ] curry timeout later
    swap session-alarm >box ;

: session ( -- assoc ) \ session get namespace>> ;

: sget ( key -- value ) session at ;

: sset ( value key -- ) session set-at ;

: schange ( key quot -- ) session swap change-at ; inline

: new-session ( responder -- id )
    [ sessions>> generate-key dup ] keep
    [ <session> dup touch-session ] keep
    [ swap \ session [ responder>> init-session ] with-variable ] 2keep
    >r over r> sessions>> set-at ;

: get-session ( id responder -- session )
    sessions>> tuck at* [
        nip dup touch-session
    ] [
        2drop f
    ] if ;

: call-responder/session ( request path responder session -- response )
    \ session set responder>> call-responder ;

: sessions ( -- manager/f )
    \ session get dup [ manager>> ] when ;

GENERIC: session-link* ( url query sessions -- string )

M: object session-link* 2drop url-encode ;

: session-link ( url query -- string ) sessions session-link* ;

TUPLE: url-sessions ;

: <url-sessions> ( responder -- responder' )
    url-sessions <session-manager> ;

: sess-id "factorsessid" ;

M: url-sessions call-responder ( request path responder -- response )
    pick sess-id query-param over get-session [
        call-responder/session
    ] [
        new-session nip sess-id set-query-param
        dup request-url <temporary-redirect>
    ] if* ;

M: url-sessions session-link*
    drop
    \ session get id>> sess-id associate union assoc>query
    >r url-encode r>
    dup assoc-empty? [ drop ] [ "?" swap 3append ] if ;

TUPLE: cookie-sessions ;

: <cookie-sessions> ( responder -- responder' )
    cookie-sessions <session-manager> ;

: get-session-cookie ( request responder -- cookie )
    >r sess-id get-cookie dup
    [ value>> r> get-session ] [ r> 2drop f ] if ;

: <session-cookie> ( id -- cookie )
    sess-id <cookie> ;

M: cookie-sessions call-responder ( request path responder -- response )
    3dup nip get-session-cookie [
        call-responder/session
    ] [
        dup new-session
        [ over get-session call-responder/session ] keep
        <session-cookie> put-cookie
    ] if* ;
