! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: http math namespaces io strings kernel html html.elements 
hashtables continuations quotations parser generic
sequences http.server.responders.callback http.server.responders ;
IN: http.server.responders.continuation

#! Used inside the session state of responders to indicate whether the
#! next request should use the post-refresh-get pattern. It is set to
#! true after each request.
SYMBOL: post-refresh-get?

: >callable ( quot|interp|f -- interp )
    dup continuation? [        
        [ continue ] curry
    ] when ;

: forward-to-url ( url -- )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    [ 
        "HTTP/1.1 302 Document Moved\nLocation: " % %
        "\nContent-Length: 0\nContent-Type: text/plain\n\n" %
    ] "" make write exit-continuation get continue ;

: forward-to-id ( id -- )
    #! When executed inside a 'show' call, this will force a
    #! HTTP 302 to occur to instruct the browser to forward to
    #! the request URL.
    >r "request" get r> id>url append forward-to-url ;

SYMBOL: current-show

: store-current-show ( -- )
  #! Store the current continuation in the variable 'current-show' 
  #! so it can be returned to later by href callbacks. Note that it
  #! recalls itself when the continuation is called to ensure that
  #! it resets its value back to the most recent show call.
  [  ( 0 -- )
    [ ( 0 1 -- )
      current-show set ( 0 -- )
      continue
    ] callcc1 ! 0 [ ] ==
    nip
    restore-request
    call
    store-current-show
  ] callcc0 restore-request ;

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
      >callable t register-callback forward-to-url
    ] callcc0  restore-request
  ] [
    t post-refresh-get? set
  ] if ;

: (show) ( quot -- hashtable )   
    #! See comments for show. The difference is the 
    #! quotation MUST set the content-type using 'serving-html'
    #! or similar.
    store-current-show redirect-to-here
    [ 
        >callable t register-callback swap with-scope 
        exit-continuation get  continue
    ] callcc0 drop restore-request "response" get ;

: show ( quot -- namespace )   
    #! Call the quotation with the URL associated with the current
    #! continuation. All output from the quotation goes to the client
    #! browser. When the URL is later referenced then 
    #! computation will resume from this 'show' call with a hashtable on
    #! the stack containing any query or post parameters.
    #! 'quot' has stack effect ( url -- )
    #! NOTE: On return from 'show' the stack is exactly the same as
    #! initial entry with 'quot' popped off and the hashtable pushed on. Even
    #! if the quotation consumes items on the stack.
    [ serving-html ] swap append (show) ;

: (show-final) ( quot -- namespace )
    #! See comments for show-final. The difference is the 
    #! quotation MUST set the content-type using 'serving-html'
    #! or similar.
    store-current-show redirect-to-here
    with-scope exit-continuation get continue ;

: show-final ( quot -- namespace )
    #! Similar to 'show', except the quotation does not receive the URL
    #! to resume computation following 'show-final'. No continuation is
    #! stored for this resumption. As a result, 'show-final' is for use
    #! when a page is to be displayed with no further action to occur. Its
    #! use is an optimisation to save having to generate and save a continuation
    #! in that special case.
    #! 'quot' has stack effect ( -- ).
    [ serving-html ] swap append (show-final) ;

#! Name of variable for holding initial continuation id that starts
#! the responder.
SYMBOL: root-callback

: cont-get/post-responder ( id-or-f -- ) 
    #! httpd responder that handles the root continuation request.
    #! The requests for actual continuation are processed by the
    #! 'callback-responder'.
    [         
        [ f post-refresh-get? set <request> request set root-callback get call ] with-scope
        exit-continuation get continue
    ] with-exit-continuation  drop ;

: quot-url ( quot -- url )
    current-show get [ continue-with ] 2curry t register-callback ;

: quot-href ( text quot -- )
    #! Write to standard output an HTML HREF where the href,
    #! when referenced, will call the quotation and then return
    #! back to the most recent 'show' call (via the callback-cc).
    #! The text of the link will be the 'text' argument on the 
    #! stack.
    <a quot-url =href a> write </a> ;

: install-cont-responder ( name quot -- )
    #! Install a cont-responder with the given name
    #! that will initially run the given quotation.
    #!
    #! Convert the quotation so it is run within a session namespace
    #! and that namespace is initialized first.
    [ 
        [ cont-get/post-responder ] "get" set 
        [ cont-get/post-responder ] "post" set 
        swap "responder" set
        root-callback set        
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
