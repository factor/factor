! Copyright (C) 2004 Chris Double.
! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: html http http.server io kernel math namespaces
continuations calendar sequences assocs new-slots hashtables
accessors arrays alarms quotations combinators ;
IN: http.server.callbacks

SYMBOL: responder

TUPLE: callback-responder responder callbacks ;

: <callback-responder> ( responder -- responder' )
    #! A continuation responder is a special type of session
    #! manager. However it works entirely differently from
    #! the URL and cookie session managers.
    H{ } clone callback-responder construct-boa ;

TUPLE: callback cont quot expires alarm responder ;

: timeout 20 minutes ;

: timeout-callback ( callback -- )
    dup alarm>> cancel-alarm
    dup responder>> callbacks>> delete-at ;

: touch-callback ( callback -- )
    dup expires>> [
        dup alarm>> [ cancel-alarm ] when*
        dup [ timeout-callback ] curry timeout later >>alarm
    ] when drop ;

: <callback> ( cont quot expires? -- callback )
    [ f responder get callback construct-boa ] keep
    [ dup touch-callback ] when ;

: invoke-callback ( request exit-cont callback -- response )
    [ quot>> 3array ] keep cont>> continue-with ;

: register-callback ( cont quot expires? -- id )
    <callback>
    responder get callbacks>> generate-key
    [ responder get callbacks>> set-at ] keep ;

SYMBOL: exit-continuation

: exit-with exit-continuation get continue-with ;

: forward-to-url ( url -- * )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    <temporary-redirect> exit-with ;

: cont-id "factorcontid" ;

: id>url ( id -- url )
    request get clone
    swap cont-id associate >>query
    request-url ;

: forward-to-id ( id -- * )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    id>url forward-to-url ;

: restore-request ( pair -- )
    first3 >r exit-continuation set request set r> call ;

: resume-page ( request page responder callback -- * )
    dup touch-callback
    >r 2drop exit-continuation get
    r> invoke-callback ;

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
    [
        >r store-current-show redirect-to-here r> call exit-with
    ] with-scope ; inline

M: callback-responder call-responder
    [
        [
            exit-continuation set
            dup responder set
            pick request set
            pick cont-id query-param over callbacks>> at [
                resume-page
            ] [
                responder>> call-responder
                "Continuation responder pages must use show-final" throw
            ] if*
        ] with-scope
    ] callcc1 >r 3drop r> ;

: show-page ( quot -- )
    [
        >r store-current-show redirect-to-here r>
        [
            [ ] register-callback
            call
            exit-with
        ] callcc1 restore-request
    ] with-scope ; inline

: quot-id ( quot -- id )
    current-show get swap t register-callback ;

: quot-url ( quot -- url )
    quot-id id>url ;

! SYMBOL: current-show
! 
! : store-current-show ( -- )
!   #! Store the current continuation in the variable 'current-show'
!   #! so it can be returned to later by href callbacks. Note that it
!   #! recalls itself when the continuation is called to ensure that
!   #! it resets its value back to the most recent show call.
!   [  ( 0 -- )
!       [ ( 0 1 -- )
!           current-show set ( 0 -- )
!           continue
!       ] callcc1
!       nip
!       store-current-show
!   ] callcc0 ;
! 

! 
! : show-final ( quot -- * )
!     store-current-show
!     redirect-to-here
!     call
!     exit-with ; inline
! 
! : show-page ( quot -- request )
!     store-current-show redirect-to-here
!     [
!         register-continuation
!         call
!         exit-with
!     ] callcc1 restore-request ; inline
