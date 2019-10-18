! Copyright (C) 2004 Chris Double.
! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http http.server io kernel math namespaces
continuations calendar sequences assocs hashtables
accessors arrays alarms quotations combinators fry
http.server.redirection furnace assocs.lib urls ;
IN: furnace.callbacks

SYMBOL: responder

TUPLE: callback-responder responder callbacks ;

: <callback-responder> ( responder -- responder' )
    H{ } clone callback-responder boa ;

TUPLE: callback cont quot expires alarm responder ;

: timeout 20 minutes ;

: timeout-callback ( callback -- )
    [ alarm>> cancel-alarm ]
    [ dup responder>> callbacks>> delete-at ]
    bi ;

: touch-callback ( callback -- )
    dup expires>> [
        dup alarm>> [ cancel-alarm ] when*
        dup '[ , timeout-callback ] timeout later >>alarm
    ] when drop ;

: <callback> ( cont quot expires? -- callback )
    f callback-responder get callback boa
    dup touch-callback ;

: invoke-callback ( callback -- response )
    [ touch-callback ]
    [ quot>> request get exit-continuation get 3array ]
    [ cont>> continue-with ]
    tri ;

: register-callback ( cont quot expires? -- id )
    <callback> callback-responder get callbacks>> set-at-unique ;

: forward-to-url ( url -- * )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    <temporary-redirect> exit-with ;

: cont-id "factorcontid" ;

: forward-to-id ( id -- * )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    <url>
        swap cont-id set-query-param forward-to-url ;

: restore-request ( pair -- )
    first3 exit-continuation set request set call ;

SYMBOL: post-refresh-get?

: redirect-to-here ( -- )
    #! Force a redirect to the client browser so that the browser
    #! goes to the current point in the code. This forces an URL
    #! change on the browser so that refreshing that URL will
    #! immediately run from this code point. This prevents the
    #! "this request will issue a POST" warning from the browser
    #! and prevents re-running the previous POST logic. This is
    #! known as the 'post-refresh-get' pattern.
    post-refresh-get? get [
        [
            [ ] t register-callback forward-to-id
        ] callcc1 restore-request
    ] [
        post-refresh-get? on
    ] if ;

SYMBOL: current-show

: store-current-show ( -- )
    #! Store the current continuation in the variable 'current-show'
    #! so it can be returned to later by 'quot-id'. Note that it
    #! recalls itself when the continuation is called to ensure that
    #! it resets its value back to the most recent show call.
    [ current-show set f ] callcc1
    [ restore-request store-current-show ] when* ;

: show-final ( quot -- * )
    [ redirect-to-here store-current-show ] dip
    call exit-with ; inline

: resuming-callback ( responder request -- id )
    url>> cont-id query-param swap callbacks>> at ;

M: callback-responder call-responder* ( path responder -- response )
    '[
        , ,

        [ callback-responder set ]
        [ request get resuming-callback ] bi

        [
            invoke-callback
        ] [
            callback-responder get responder>> call-responder
        ] ?if
    ] with-exit-continuation ;

: show-page ( quot -- )
    [ redirect-to-here store-current-show ] dip
    [
        [ ] t register-callback swap call exit-with
    ] callcc1 restore-request ; inline

: quot-id ( quot -- id )
    current-show get swap t register-callback ;

: quot-url ( quot -- url )
    quot-id f swap cont-id associate derive-url ;
