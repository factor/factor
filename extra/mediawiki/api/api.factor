! Copyright (C) 2021, 2022 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays accessors assocs assocs.extras calendar
combinators combinators.short-circuit continuations formatting
http http.client io json kernel locals make math math.parser
namespaces oauth1 prettyprint sequences strings system threads ;
IN: mediawiki.api

TUPLE: oauth-login consumer-token consumer-secret access-token
access-secret ;
TUPLE: password-login username password ;

C: <oauth-login> oauth-login
C: <password-login> password-login

SYMBOLS: botflag contact cookies csrf-token endpoint oauth-login
password-login ;

<PRIVATE

SYMBOLS: basetimestamp curtimestamp ;

PRIVATE>

t botflag set-global

<PRIVATE

: prepare ( params -- params' )
    [ {
        { [ dup t = ] [ drop "true" ] }
        { [ dup number? ] [ number>string ] }
        { [ dup string? ] [ ] }
        { [ dup sequence? ] [
            [ {
                { [ dup number? ] [ number>string ] }
                [ ]
            } cond ] map "|" join
        ] }
    } cond ] assoc-map ;

: <api-request> ( params -- request )
        {
            { "format" "json" }
            { "formatversion" 2 }
            { "maxlag" 5 }
        } swap assoc-union prepare
        endpoint get
    <post-request>
        contact get vm-version vm-git-id 7 head
        "%s Factor/%s %s mediawiki.api" sprintf "User-Agent"
        set-header ;

: oauth-post ( params -- response data )
    oauth-login get
        dup consumer-token>>
        over consumer-secret>> <token> consumer-token set
        dup access-token>>
        swap access-secret>> <token> access-token set
    <api-request>
        <oauth-request-params> set-oauth
    http-request ;

: cookie-post* ( params -- assoc )
    <api-request>
        cookies get >>cookies
    http-request [ cookies>> cookies set-global ] dip json> ;

: login-token ( -- token )
    {
        { "action" "query" }
        { "meta" "tokens" }
        { "type" "login" }
    } cookie-post*
    { "query" "tokens" "logintoken" } deep-of ;

: login ( -- cookies )
    [
        "login" "action" ,,
        password-login get dup username>> "lgname" ,,
        password>> "lgpassword" ,,
        login-token "lgtoken" ,,
    ] { } make cookie-post* drop cookies get ;

: cookie-post ( params -- response data )
    <api-request>
        cookies get [ login ] unless* >>cookies
    http-request ;

: anon-post ( params -- response data )
    <api-request> http-request ;

: code-200? ( response assoc -- ? )
    over code>> dup 200 = dup [ 3nip ] [
        -roll "http status code %d" printf
        swap header>> [ "=" glue print ] assoc-each
        ...
        10 minutes sleep
    ] if ;

: retry-after? ( response -- ? )
    header>> "retry-after" of [ string>number dup seconds sleep ] ?call ;

: nonce-already-used? ( assoc -- ? )
    "error" of
    [ "code" of "mwoauth-invalid-authorization" = ]
    [ "info" of "Nonce already used" subseq-of? ] bi
    and ;

: readonly? ( assoc -- ? )
    { "error" "code" } deep-of "readonly" = dup
    [ 5 minutes sleep ] when ;

DEFER: get-csrf-token
: badtoken? ( assoc -- ? )
    { "error" "code" } deep-of "badtoken" = dup
    [ get-csrf-token drop ] when ;

: failed? ( response assoc -- response assoc ? )
    2dup {
        [ code-200? not ]
        [ drop retry-after? ]
        [ nip nonce-already-used? ]
        [ nip readonly? ]
        [ nip badtoken? ]
    } 2|| ;

: dispatch-call ( params -- response data )
    {
        { [ oauth-login get ] [ oauth-post ] }
        { [ password-login get ] [ cookie-post ] }
        [ anon-post ]
    } cond ;

PRIVATE>

: api-call ( params -- assoc )
    f f [
        failed?
    ] [
        2drop dup dispatch-call
        [ json> ] [ swap print rethrow ] recover
        "warnings" "errors" [ over at [ ... ] when* ] bi@
    ] do while 2nip ;

<PRIVATE

:: (query) ( params -- obj assoc )
    { { "action" "query" } } params assoc-union api-call dup
    [ "query" of ] transmute
    "siprop" params key? [
        params { "prop" "list" "meta" } values-of sift first of
    ] unless swap ;

PRIVATE>

:: call-continue ( params quot1: ( params -- obj assoc )
quot2: ( ... -- ... ) -- seq )
    f f [
        "continue" of
    ] [
        params assoc-union quot1 call
        [ quot2 call >alist append ] dip
    ] do while* ; inline

: query ( params -- seq )
    [ (query) ] [ ] call-continue ;

:: page-content ( title -- content )
    {
        { "action" "query" }
        { "prop" "revisions" }
        { "rvprop" { "content" "timestamp" } }
        { "rvlimit" 1 }
        { "rvslots" "main" }
        { "titles" title }
        { "curtimestamp" t }
    } api-call
    [ "curtimestamp" of curtimestamp set-global ]
    [
        "query" of "pages" "revisions" [ of first ] bi@
        [ "timestamp" of basetimestamp set-global ]
        [ { "slots" "main" "content" } deep-of ] bi
    ] bi ;

<PRIVATE

: get-csrf-token ( -- csrf-token )
    {
        { "meta" "tokens" }
        { "type" "csrf" }
    } query
    "csrftoken" of dup csrf-token set-global ;

PRIVATE>

: token-call ( params -- assoc )
    [
        %%
        csrf-token get [ get-csrf-token ] unless* "token" ,,
    ] { } make api-call ;

:: edit-page ( title text summary params -- assoc )
    [
        "edit" "action" ,,
        title "title" ,,
        summary "summary" ,,
        text "text" ,,
        curtimestamp get "now" or "starttimestamp" ,,
        basetimestamp get "now" or "basetimestamp" ,,
    ] { } make
    botflag get { { "bot" t } } { } ?
    params [ assoc-union ] bi@ token-call ;

:: move-page ( from to reason params -- assoc )
    {
        { "action" "move" }
        { "from" from }
        { "to" to }
        { "reason" reason }
        { "movetalk" t }
    } params assoc-union token-call ;

:: email ( target subject text -- assoc )
    {
        { "action" "emailuser" }
        { "target" target }
        { "subject" subject }
        { "text" text }
    } token-call ;
