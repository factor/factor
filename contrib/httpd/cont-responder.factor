! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: http httpd math namespaces io
strings kernel html hashtables
parser generic sequences ;
IN: cont-responder

#! Used inside the session state of responders to indicate whether the
#! next request should use the post-refresh-get pattern. It is set to
#! true after each request.
SYMBOL: post-refresh-get?

: expiry-timeout ( -- timeout-seconds )
    #! Number of seconds to timeout continuations in
    #! continuation table. This value will need to be
    #! tuned. I leave it at 24 hours but it can be
    #! higher/lower as needed. Default to 15 minutes for
    #! testing.
    900 ;

: get-random-id ( -- id ) 
    #! Generate a random id to use for continuation URL's
    [ "ID" % 32 [ 9 random-int CHAR: 0 + , ] times ] "" make ;

SYMBOL: table

: continuation-table ( -- <hashtable> ) 
    #! Return the global table of continuations
    table get-global ;

: reset-continuation-table ( -- ) 
    #! Create the initial global table
    continuation-table clear-hash ;

H{ } clone table set-global

#! Tuple for holding data related to a continuation.
TUPLE: item expire? quot id time-added ;

: continuation-item ( expire? quot id -- <item> )
    #! A continuation item is the actual item stored
    #! in the continuation table. It contains the id,
    #! quotation/continuation, time added, etc. If
    #! expire? is true then the continuation will
    #! be expired after a certain amount of time.
    millis <item> ;  

: seconds>millis ( seconds -- millis )
    #! Convert a number of seconds to milliseconds
    1000 * ;

: expired? ( timeout-seconds <item> -- bool )
    #! Return true if the continuation item is expirable
    #! and has expired (ie. was added to the table more than
    #! timeout milliseconds ago).
    [ item-time-added swap seconds>millis + millis - 0 < ] keep item-expire? and ;

: expire-continuations ( timeout-seconds -- )
    #! Expire all continuations in the continuation table
    #! if they are 'timeout-seconds' old (ie. were added
    #! more than 'timeout-seconds' ago.
    continuation-table clone [
        swapd expired? [
            continuation-table remove-hash
        ] [
            drop
        ] if
    ] hash-each-with ;

: expirable ( quot -- t quot )
    #! Set the stack up for a register-continuation call 
    #! so that the given quotation is registered that it can
    #! be expired.
    t swap ;

: permanent ( quot -- f quot )
    #! Set the stack up for a register-continuation call
    #! so that the given quotation is never expired after
    #! registration.
    f swap ;

: register-continuation ( expire? quot -- id ) 
    #! Store a continuation in the table and associate it with
    #! a random id. That continuation will be expired after
    #! a certain period of time if 'expire?' is true.  
    get-random-id 
    [ continuation-item ] keep ( item id -- )
    [ continuation-table set-hash ] keep ;

: register-continuation* ( expire? quots -- id ) 
    #! Like register-continuation but registers a quotation 
    #! that will call all quotations in the list, in the order given.
    concat register-continuation ;

: get-continuation-item ( id -- <item> )
    #! Get the continuation item associated with the id.
    continuation-table hash ;

: id>url ( id -- string )
    #! Convert the continuation id to an URL suitable for
    #! embedding in an HREF or other HTML.
    url-encode "?id=" swap append ;

DEFER: show-final
DEFER: show 

TUPLE: resume value stdio ;

: (expired-page-handler) ( alist -- )
    #! Display a page has expired message.
    #! TODO: Need to handle this better to enable
    #!       returning back to root continuation.
    <html>                
        <body> 
        <p> "This page has expired." write  </p> 
        </body>
    </html> flush  ;

: expired-page-handler ( alist -- )
    [ (expired-page-handler) ] show-final ;

: >callable ( quot|interp|f -- interp )
    dup continuation? [
        [ continue-with ] curry
    ] when ;

: get-registered-continuation ( id -- cont ) 
    #! Return the continuation or quotation 
    #! associated with the given id.  
    #! TODO: handle expired pages better.
    expiry-timeout expire-continuations
    get-continuation-item [
        item-quot
    ] [
        [ (expired-page-handler) ]
    ] if* >callable ;

: resume-continuation ( resumed-data id  -- ) 
    #! Call the continuation associated with the given id,
    #! with 'value' on the top of the stack.
    get-registered-continuation call ;

#! Name of the variable holding the continuation used to exit
#! back to the httpd responder, returning any generated HTML.
SYMBOL: exit-cc 

: exit-continuation ( -- exit ) 
    #! Get the current exit continuation
    exit-cc get ;

: call-exit-continuation ( value -- ) 
    #! Call the exit continuation, passing it the given value on the
    #! top of the stack.
    exit-cc get continue-with ;

: with-exit-continuation ( quot -- ) 
    #! Call the quotation with the variable exit-cc bound such that when
    #! the exit continuation is called, computation will resume from the
    #! end of this 'with-exit-continuation' call, with the value passed
    #! to the exit continuation on the top of the stack.
    [ exit-cc set call f call-exit-continuation ] callcc1 nip ;

#! Name of variable holding the 'callback' continuation, used for
#! returning back to previous 'show' calls.
SYMBOL: callback-cc

: store-callback-cc ( -- )
    #! Store the current continuation in the variable 'callback-cc' 
    #! so it can be returned to later by callbacks. Note that it
    #! recalls itself when the continuation is called to ensure that
    #! it resets its value back to the most recent show call.
    [  ( 0 -- )
        [ ( 0 1 -- )
            callback-cc set ( 0 -- )
            stdio get swap continue-with
        ] callcc1
        nip
        dup resume-stdio stdio set
        resume-value call
        store-callback-cc stdio get 
    ] callcc1 stdio set ;

: forward-to-url ( url -- )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    [ 
        "HTTP/1.1 302 Document Moved\nLocation: " % %
        "\nContent-Length: 0\nContent-Type: text/plain\n\n" %
    ] "" make write "" call-exit-continuation ;

: forward-to-id ( id -- )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    >r "request" get r> id>url append forward-to-url ;

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
            expirable register-continuation forward-to-id
        ] callcc1 resume-stdio stdio set
    ] [
        t post-refresh-get? set
    ] if ;

: (show) ( quot -- namespace )   
    #! See comments for show. The difference is the 
    #! quotation MUST set the content-type using 'serving-html'
    #! or similar.
    store-callback-cc  redirect-to-here 
    [ 
        expirable register-continuation id>url swap 
        with-scope "" call-exit-continuation
    ] callcc1 
    nip dup resume-stdio stdio set resume-value ;

: show ( quot -- namespace )   
    #! Call the quotation with the URL associated with the current
    #! continuation. All output from the quotation goes to the client
    #! browser. When the URL is later referenced then 
    #! computation will resume from this 'show' call with a namespace on
    #! the stack containing any query or post parameters.
    #! NOTE: On return from 'show' the stack is exactly the same as
    #! initial entry with 'quot' popped off an <namespace> put on. Even
    #! if the quotation consumes items on the stack.
    [ serving-html ] swap append (show) ;

: (show-final) ( quot -- namespace )
    #! See comments for show-final. The difference is the 
    #! quotation MUST set the content-type using 'serving-html'
    #! or similar.
    store-callback-cc  redirect-to-here 
    with-scope "" call-exit-continuation ;

: show-final ( quot -- namespace )
    #! Similar to 'show', except the quotation does not receive the URL
    #! to resume computation following 'show-final'. No continuation is
    #! stored for this resumption. As a result, 'show-final' is for use
    #! when a page is to be displayed with no further action to occur. Its
    #! use is an optimisation to save having to generate and save a continuation
    #! in that special case.
    [ serving-html ] swap append (show-final) ;

#! Name of variable for holding initial continuation id that starts
#! the responder.
SYMBOL: root-continuation

: id-or-root ( -- id )
    #! Return the continuation id for the current requested continuation
    #! or the root continuation if no id is supplied.
    "id" query-param [ root-continuation get ] unless* ;

: cont-get/post-responder ( id-or-f -- ) 
    #! httpd responder that retrieves a continuation and calls it.
    #! The continuation id must be in a query parameter called 'id'.
    #! If it does not exist the root continuation is called. If
    #! no root continuation exists the expired continuation handler
    #! should be called.
    [
        drop [
            "response" get stdio get <resume>
            id-or-root [
                resume-continuation
            ] [
                (expired-page-handler) "" call-exit-continuation
            ] if* 
        ] with-exit-continuation drop
    ] with-scope ;

: callback-quot ( quot -- quot )
    #! Convert the given quotation so it works as a callback
    #! by returning a quotation that will pass the original 
    #! quotation to the callback continuation.
    [
        , [ stdio get <resume> ] %
        callback-cc get ,
        \ continue-with ,
    ] [ ] make ;

: quot-url ( quot -- url )
    callback-quot expirable register-continuation id>url ;

: quot-href ( text quot -- )
    #! Write to standard output an HTML HREF where the href,
    #! when referenced, will call the quotation and then return
    #! back to the most recent 'show' call (via the callback-cc).
    #! The text of the link will be the 'text' argument on the 
    #! stack.
    <a quot-url =href a> write </a> ;

: init-session-namespace ( <resume> -- )
    #! Setup the initial session namespace. Currently this only
    #! sets the redirect flag so that the initial request of the
    #! responder will not do a post-refresh-get style redirect.
    #! This prevents the initial request to a responder from redirecting
    #! to an URL with a continuation id. This word must be run from
    #! within the session namespace.
    f post-refresh-get? set dup resume-stdio stdio set ;

: prepare-cont-quot ( quot -- quot )
    [ init-session-namespace ] swap append
    [ with-scope ] curry ;

: install-cont-responder ( name quot -- )
    #! Install a cont-responder with the given name
    #! that will initially run the given quotation.
    #!
    #! Convert the quotation so it is run within a session namespace
    #! and that namespace is initialized first.
    prepare-cont-quot [ 
        [ cont-get/post-responder ] "get" set 
        [ cont-get/post-responder ] "post" set 
        swap "responder" set
        permanent register-continuation root-continuation set 
    ] make-responder ;

: simple-page ( title quot -- )
    #! Call the quotation, with all output going to the
    #! body of an html page with the given title.
    <html>  
        <head> <title> swap write </title> </head> 
        <body> call </body>
    </html> ;

: styled-page ( title stylesheet-quot quot -- )
    #! Call the quotation, with all output going to the
    #! body of an html page with the given title. stylesheet-quot
    #! is called to generate the required stylesheet.
    <html>  
        <head>  
             <title> rot write </title> 
             swap call 
        </head> 
        <body> call </body>
    </html> ;

: paragraph ( str -- )
    #! Output the string as an html paragraph
    <p> write </p> ;

: show-message-page ( message -- )
    #! Display the message in an HTML page with an OK button.
    [
        "Press OK to Continue" [
            swap paragraph 
            <a =href a> "OK" write </a>
        ] simple-page 
    ] show 2drop ;

: vertical-layout ( list -- )
    #! Given a list of HTML components, arrange them vertically.
    <table> 
    [ <tr> <td> call </td> </tr> ] each
    </table> ;

: horizontal-layout ( list -- )
    #! Given a list of HTML components, arrange them horizontally.
    <table> 
     <tr "top" =valign tr> [ <td> call </td> ] each </tr>
    </table> ;

: button ( label -- )
    #! Output an HTML submit button with the given label.
    <input "submit" =type =value input/> ;
