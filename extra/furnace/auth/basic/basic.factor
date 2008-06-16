! Copyright (c) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel splitting base64 namespaces
http http.server.responses furnace.auth ;
IN: furnace.auth.basic

TUPLE: basic-auth-realm < realm ;

C: <basic-auth-realm> basic-auth-realm

: parse-basic-auth ( header -- username/f password/f )
    dup [
        " " split1 swap "Basic" = [
            base64> ":" split1
        ] [ drop f f ] if
    ] [ drop f f ] if ;

: <401> ( realm -- response )
    401 "Invalid username or password" <trivial-response>
    [ "Basic realm=\"" % swap % "\"" % ] "" make "WWW-Authenticate" set-header ;

M: basic-auth-realm login-required* ( realm -- response )
    name>> <401> ;

M: basic-auth-realm logged-in-username ( realm -- uid )
    request get "authorization" header parse-basic-auth
    dup [ over realm get check-login swap and ] [ 2drop f ] if ;
