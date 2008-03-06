! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.auth
USING: new-slots accessors http.server.auth.providers.null
http.server.auth.strategies.null ;

TUPLE: authentication responder provider strategy ;

: <authentication> ( responder -- authentication )
    null-auth-provider null-auth-strategy
    authentication construct-boa ;

SYMBOL: current-user-id
SYMBOL: auth-provider
SYMBOL: auth-strategy

M: authentication call-responder ( request path responder -- response )
    dup provider>> auth-provider set
    dup strategy>> auth-strategy set
    pick auth-provider get logged-in? dup current-user-id set
    [
        responder>> call-responder
    ] [
        2drop auth-provider get require-login
    ] if* ;
