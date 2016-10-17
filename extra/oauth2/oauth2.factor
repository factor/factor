! Copyright (C) 2016 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs http.client io json.reader kernel
sequences unicode urls webbrowser ;
IN: oauth2

TUPLE: oauth2
    auth-uri
    token-uri
    redirect-uri
    client-id
    client-secret
    scope
    extra-params ;

: set-query-params ( url params -- url )
    [ first2 swap set-query-param ] each ;

: string+params>url ( string params -- url )
    [ >url ] dip set-query-params ;

: console-prompt ( query -- str )
    write flush readln [ blank? ] trim ;

: token-params ( oauth2 code -- params )
    [
        [
            [ client-id>> "client_id" swap 2array ]
            [ client-secret>> "client_secret" swap 2array ]
            [ redirect-uri>> "redirect_uri" swap 2array ] tri 3array
        ] [ extra-params>> ] bi append
    ] [
        "code" swap 2array
    ] bi* suffix {
        { "grant_type" "authorization_code" }
    } append ;

: auth-params ( oauth2 -- params )
    [
        [ client-id>> "client_id" swap 2array ]
        [ scope>> "scope" swap 2array ]
        [ redirect-uri>> "redirect_uri" swap 2array ] tri 3array
    ] [ extra-params>> ] bi append {
        { "response_type" "code" }
        { "access_type" "offline" }
    } append ;

: oauth2>auth-uri ( oauth2 -- uri )
    [ auth-uri>> ] [ auth-params ] bi string+params>url ;

: post-token-request ( params token-uri -- token )
    <post-request> dup header>> "application/json" "Accept" rot set-at
    http-request nip json> "access_token" of ;

! Other flows can be useful to support too.
: console-flow ( oauth2 -- token )
    [ oauth2>auth-uri open-url ] [
        [ "Enter verification code: " console-prompt token-params ]
        [ token-uri>> ] bi
        post-token-request
    ] bi ;

! Using the token to access secured resources.
: add-token ( request url -- )
    "Bearer " prepend "Authorization" rot header>> set-at ;

: oauth-http-get ( url token -- response data )
    [ <get-request> dup ] dip add-token http-request ;
