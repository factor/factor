! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: http httpd math namespaces io strings kernel html hashtables
       parser generic sequences callback-responder ;
IN: cont-responder

#! Name of the variable holding the continuation used to exit
#! back to the httpd responder.
SYMBOL: exit-continuation 

#! Tuple to hold global request data. This gets passed to
#! the continuation when resumed so it can restore things
#! like 'stdio' so it writes to the correct socket. 
TUPLE: request stream exitcc method url raw-query query header response ;

C: request ( -- request )
  [ stdio get swap set-request-stream ] keep 
  [ "method" get swap set-request-method ] keep 
  [ "request" get swap set-request-url ] keep 
  [ "raw-query" get swap set-request-raw-query ] keep 
  [ "query" get swap set-request-query ] keep 
  [ "header" get swap set-request-header ] keep 
  [ "response" get swap set-request-response ] keep 
  [ exit-continuation get swap set-request-exitcc ] keep ;

: restore-request ( request -- )
  dup request-stream stdio set 
  dup request-method "method" set 
  dup request-raw-query "raw-query" set 
  dup request-query "query" set 
  dup request-header "header" set 
  dup request-response "response" set 
  request-exitcc exit-continuation set ;

: >callable ( quot|interp|f -- interp )
    dup continuation? [        
        [ <request> swap continue-with ] curry 
        [ with-exit-continuation ] curry
    ] when ;

: with-exit-continuation ( quot -- ) 
    #! Call the quotation with the variable exit-continuation bound 
    #! such that when the exit continuation is called, computation 
    #! will resume from the end of this 'with-exit-continuation' call. 
    [ 
        exit-continuation set call exit-continuation get continue
    ] callcc0 drop ;

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

: (show) ( quot -- hashtable )   
    #! See comments for show. The difference is the 
    #! quotation MUST set the content-type using 'serving-html'
    #! or similar.
    [ 
        >callable t register-callback swap with-scope 
        exit-continuation get  continue
    ] callcc1 nip restore-request "response" get ;

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
        root-callback get call
        exit-continuation get continue
    ] with-exit-continuation ;

: quot-url ( quot -- url )
    t register-callback ;

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
