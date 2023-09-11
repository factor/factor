! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs base64 calendar checksums.hmac
checksums.sha http http.client kernel make math math.parser
namespaces present random sequences sorting strings
urls.encoding urls.private ;
IN: oauth1

SYMBOL: consumer-token

TUPLE: token key secret user-data ;

: <token> ( key secret -- token )
    token new
        swap >>secret
        swap >>key ;

<PRIVATE

TUPLE: token-params
consumer-token
timestamp
nonce ;

: new-token-params ( class -- params )
    new
        consumer-token get >>consumer-token
        now timestamp>unix-time >integer >>timestamp
        16 random-bytes bytes>hex-string >>nonce ; inline

: present-base-url ( url -- string )
    [
        [ unparse-protocol ]
        [ unparse-authority ]
        [ path>> url-encode % ] tri
    ] "" make ;

:: signature-base-string ( url request-method params -- string )
    [
        request-method % "&" %
        url present-base-url url-encode-full % "&" %
        params assoc>query url-encode-full %
        url query>> [ assoc>query "&" prepend url-encode-full % ] when*
    ] "" make ;

: hmac-key ( consumer-secret token-secret -- key )
    [ url-encode-full ] [ "" or url-encode-full ] bi* "&" glue ;

: make-token-params ( params quot -- assoc )
    '[
        "1.0" "oauth_version" ,,
        "HMAC-SHA1" "oauth_signature_method" ,,

        _
        [
            [ consumer-token>> key>> "oauth_consumer_key" ,, ]
            [ timestamp>> "oauth_timestamp" ,, ]
            [ nonce>> "oauth_nonce" ,, ]
            tri
        ] bi
    ] H{ } make ; inline

! Checksum all the params but only return the oauth_ params for
! use in the auth header.
! See https://github.com/factor/factor/issues/2487
:: sign-params ( url request-method consumer-token request-token params -- oauth-params )
    params sort-keys :> params
    url request-method params signature-base-string :> sbs
    consumer-token secret>> request-token dup [ secret>> ] when
    hmac-key :> key
    sbs key sha1 hmac-bytes >base64 >string :> signature
    params { "oauth_signature" signature } prefix
    [ "oauth_" head? ] filter-keys ;

: extract-user-data ( assoc -- assoc' )
    [
        { "oauth_token" "oauth_token_secret" } member? not
    ] filter-keys ;

: parse-token ( response data -- token )
    nip
    query>assoc
    [ [ "oauth_token" ] dip at ]
    [ [ "oauth_token_secret" ] dip at ]
    [ extract-user-data ]
    tri
    [ <token> ] dip >>user-data ;

PRIVATE>

TUPLE: request-token-params < token-params
{ callback-url initial: "oob" } ;

: <request-token-params> ( -- params )
    request-token-params new-token-params ;

<PRIVATE

:: <token-request> ( url consumer-token request-token params -- request )
    url "POST" consumer-token request-token params sign-params
    url
    <post-request> ;

: make-request-token-params ( params -- assoc )
    [ callback-url>> "oauth_callback" ,, ] make-token-params ;

: <request-token-request> ( url params -- request )
    [ consumer-token>> f ] [ make-request-token-params ] bi
    <token-request> ;

PRIVATE>

: obtain-request-token ( url params -- token )
    <request-token-request> http-request parse-token ;

TUPLE: access-token-params < token-params request-token verifier ;

: <access-token-params> ( -- params )
    access-token-params new-token-params ;

<PRIVATE

: make-access-token-params ( params -- assoc )
    [
        [ request-token>> key>> "oauth_token" ,, ]
        [ verifier>> "oauth_verifier" ,, ]
        bi
    ] make-token-params ;

: <access-token-request> ( url params -- request )
    [ consumer-token>> ]
    [ request-token>> ]
    [ make-access-token-params ] tri
    <token-request> ;

PRIVATE>

: obtain-access-token ( url params -- token )
    <access-token-request> http-request parse-token ;

SYMBOL: access-token

TUPLE: oauth-request-params < token-params access-token ;

: <oauth-request-params> ( -- params )
    oauth-request-params new-token-params
        access-token get >>access-token ;

<PRIVATE

:: signed-oauth-request-params ( request params -- oauth-params )
    request url>>
    request method>>
    params consumer-token>>
    params access-token>>
    params
    [
        access-token>> key>> "oauth_token" ,,
        request post-data>> %%
    ] make-token-params
    sign-params ;

: build-auth-string ( oauth-params -- string )
    [ [ present url-encode-full ] bi@ "\"" "\"" surround "=" glue ] { } assoc>map
    ", " join "OAuth realm=\"\", " prepend ;

PRIVATE>

: set-oauth ( request params -- request )
    dupd signed-oauth-request-params build-auth-string
    "Authorization" set-header ;
