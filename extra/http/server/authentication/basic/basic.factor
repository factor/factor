! Copyright (c) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.authentication.basic
USING: accessors new-slots quotations assocs kernel splitting
base64 crypto.sha2 html.elements io combinators http.server
http sequences ;

! 'users' is a quotation or an assoc. The quotation 
! has stack effect ( sha-256-string username -- ? ).
! It should perform the user authentication. 'sha-256-string'
! is the plain text password provided by the user passed through
! 'string>sha-256-string'. If 'users' is an assoc then
! it is a mapping of usernames to sha-256 hashed passwords. 
TUPLE: realm responder name users ;

C: <realm> realm

: user-authorized? ( password username realm -- ? )
    users>> {
        { [ dup callable? ] [ call ] }
        { [ dup assoc? ] [ at = ] }
    } cond ;

: authorization-ok? ( realm header -- bool )  
    #! Given the realm and the 'Authorization' header,
    #! authenticate the user.
    dup [
        " " split1 swap "Basic" = [
            base64> ":" split1 string>sha-256-string
            spin user-authorized?
        ] [
            2drop f
        ] if
    ] [
        2drop f
    ] if ;

: <401> ( realm -- response )
    401 "Unauthorized" <trivial-response>
    "Basic realm=\"" rot name>> "\"" 3append
    "WWW-Authenticate" set-header
    [
        <html> <body>
            "Username or Password is invalid" write
        </body> </html>
    ] >>body ;

M: realm call-responder ( request path realm -- response )
    pick "authorization" header dupd authorization-ok?
    [ responder>> call-responder ] [ 2nip <401> ] if ;
