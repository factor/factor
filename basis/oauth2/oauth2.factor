! Copyright (C) 2016 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators http http.client io
json kernel make math.order sequences unicode urls webbrowser ;
IN: oauth2

: console-prompt ( query -- str/f )
    write flush readln [ blank? ] trim [ f ] when-empty ;

: post-json-request ( params token-uri -- assoc )
    <post-request> "application/json" "Accept" set-header
    http-request nip json> ;

TUPLE: tokens access refresh expiry ;

: assoc>expiry ( json -- expiry )
    "expires_in" of [ seconds now time+ ] [ f ] if* ;

: assoc>tokens ( json -- tokens )
    [ "access_token" of ]
    [ "refresh_token" of ]
    [ assoc>expiry ] tri tokens boa ;

: access-expired? ( tokens -- ? )
    expiry>> [ now before? ] [ f ] if* ;

: update-tokens ( tokens1 tokens2 -- tokens1 )
    2dup expiry>> >>expiry drop access>> >>access ;

TUPLE: oauth2
    auth-uri
    token-uri
    redirect-uri
    client-id
    client-secret
    scope
    extra-params ;

: tokens-params ( oauth2 code -- params )
    [
        "code" ,,
        {
            [ client-id>> "client_id" ,, ]
            [ client-secret>> "client_secret" ,, ]
            [ redirect-uri>> "redirect_uri" ,, ]
            [ extra-params>> %% ]
        } cleave
        "authorization_code" "grant_type" ,,
    ] { } make ;

: refresh-params ( oauth2 refresh -- params )
    [
        "refresh_token" ,,
        [ client-id>> "client_id" ,, ]
        [ client-secret>> "client_secret" ,, ]
        [ extra-params>> %% ] tri
        "refresh_token" "grant_type" ,,
    ] { } make ;

: auth-params ( oauth2 -- params )
    [
        {
            [ client-id>> "client_id" ,, ]
            [ scope>> "scope" ,, ]
            [ redirect-uri>> "redirect_uri" ,, ]
            [ extra-params>> %% ]
        } cleave
        "code" "response_type" ,,
        "offline" "access_type" ,,
    ] { } make ;

: oauth2>auth-uri ( oauth2 -- uri )
    [ auth-uri>> >url ] [ auth-params ] bi set-query-params ;

! Other flows can be useful to support too.
: console-flow ( oauth2 -- tokens/f )
    dup oauth2>auth-uri open-url
    "Enter verification code: " console-prompt
    [
        dupd tokens-params swap token-uri>> post-json-request
        assoc>tokens
    ] [ drop f ] if* ;

: refresh-flow ( oauth2 tokens -- tokens' )
    dupd refresh>> refresh-params swap token-uri>> post-json-request
    assoc>tokens ;

: oauth-http-get ( url access-token -- response data )
    [ <get-request> ] dip set-bearer-auth http-request ;
