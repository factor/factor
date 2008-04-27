! Copyright (c) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors quotations assocs kernel splitting
base64 html.elements io combinators http.server
http.server.auth.providers http.server.auth.providers.null
http sequences ;
IN: http.server.auth.basic

TUPLE: basic-auth < filter-responder realm provider ;

C: <basic-auth> basic-auth

: authorization-ok? ( provider header -- ? )
    #! Given the realm and the 'Authorization' header,
    #! authenticate the user.
    dup [
        " " split1 swap "Basic" = [
            base64> ":" split1 spin check-login
        ] [
            2drop f
        ] if
    ] [
        2drop f
    ] if ;

: <401> ( realm -- response )
    401 "Unauthorized" <trivial-response>
    "Basic realm=\"" rot "\"" 3append
    "WWW-Authenticate" set-header
    [
        <html> <body>
            "Username or Password is invalid" write
        </body> </html>
    ] >>body ;

: logged-in? ( request responder -- ? )
    provider>> swap "authorization" header authorization-ok? ;

M: basic-auth call-responder* ( request path responder -- response )
    pick over logged-in?
    [ call-next-method ] [ 2nip realm>> <401> ] if ;
