! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
IN: cont-responder
USING: stdio http httpd math random namespaces streams
       lists strings kernel html unparser hashtables
       parser generic sequences ;

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
  [ 32 [ random-digit unparse , ] times ] make-string str>number 36 >base ;

#! Name of variable holding the table of continuations.
SYMBOL: table 

: continuation-table ( -- <namespace> ) 
  #! Return the global table of continuations
  table get ;
    
: reset-continuation-table ( -- ) 
  #! Create the initial global table
  <namespace> table set ;

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

: continuation-items ( -- alist )
  #! Return an alist of all continuation items in the continuation
  #! table with the car as the id and the cdr as the item.
  continuation-table hash>alist ;

: expire-continuations ( timeout-seconds -- )
  #! Expire all continuations in the continuation table
  #! if they are 'timeout-seconds' old (ie. were added
  #! more than 'timeout-seconds' ago.
  continuation-items [ 
    uncons pick swap expired? [
      continuation-table remove-hash
    ] [
      drop
    ] ifte
  ] each drop ;

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
  get-random-id -rot pick continuation-item over continuation-table set-hash ;
  
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
  url-encode "?id=" swap cat2 ;

DEFER: show-final
DEFER: show 

: expired-page-handler ( alist -- )
  #! Display a page has expired message.
  #! TODO: Need to handle this better to enable
  #!       returning back to root continuation.
  drop
  [ 
    <html>                
      <body> 
       <p> "This page has expired." write  </p> 
      </body>
    </html> 
  ] show-final ;

: get-registered-continuation ( id -- cont ) 
  #! Return the continuation or quotation 
  #! associated with the given id.  
  #! TODO: handle expired pages better.
  expiry-timeout expire-continuations
  get-continuation-item [
    item-quot
  ] [
    [ expired-page-handler ]
  ] ifte* ;

: resume-continuation ( value id  -- ) 
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
  exit-cc get call ;

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
      call 
    ] callcc1 ( 0 [ ] == )
    nip
    call 
    store-callback-cc
  ] callcc0 ;

: forward-to-url ( url -- )
  #! When executed inside a 'show' call, this will force a
  #! HTTP 302 to occur to instruct the browser to forward to
  #! the request URL.
  [ 
    "HTTP/1.1 302 Document Moved\nLocation: " , ,
    "\nContent-Length: 0\nContent-Type: text/plain\n\n" , 
  ] make-string call-exit-continuation ;

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
      expirable register-continuation 
      id>url forward-to-url
    ] callcc1 drop 
  ] [
    t post-refresh-get? set
  ] ifte ;
  
: show ( quot -- namespace )   
  #! Call the quotation with the URL associated with the current
  #! continuation. Return the HTML string generated by that code
  #! to the exit continuation. When the URL is later referenced then 
  #! computation will resume from this 'show' call with a namespace on
  #! the stack containing any query or post parameters.
  #! NOTE: On return from 'show' the stack is exactly the same as
  #! initial entry with 'quot' popped off an <namespace> put on. Even
  #! if the quotation consumes items on the stack.
  store-callback-cc  redirect-to-here 
  [ 
    expirable register-continuation id>url swap 
    \ serving-html swons with-string call-exit-continuation
  ] callcc1 
  nip ;

: show-final ( quot -- namespace )
  #! Similar to 'show', except the quotation does not receive the URL
  #! to resume computation following 'show-final'. No continuation is
  #! stored for this resumption. As a result, 'show-final' is for use
  #! when a page is to be displayed with no further action to occur. Its
  #! use is an optimisation to save having to generate and save a continuation
  #! in that special case.
  store-callback-cc  redirect-to-here 
  \ serving-html swons with-string call-exit-continuation ;

#! Name of variable for holding initial continuation id that starts
#! the responder.
SYMBOL: root-continuation

: id-or-root ( -- id )
  #! Return the continuation id for the current requested continuation
  #! or the root continuation if no id is supplied.
  "id" "query" get assoc [ root-continuation get ] unless* ;

: cont-get/post-responder ( id-or-f -- ) 
  #! httpd responder that retrieves a continuation and calls it.
  #! The continuation id must be in a query parameter called 'id'.
  #! If it does not exist the root continuation is called. If
  #! no root continuation exists the expired continuation handler
  #! should be called.
  drop [
    "response" get alist>hash 
     id-or-root [
      resume-continuation
    ] [
      expired-page-handler 
    ] ifte* 
  ] with-exit-continuation [ write flush ] when* ;

: callback-quot ( quot -- quot )
  #! Convert the given quotation so it works as a callback
  #! by returning a quotation that will pass the original 
  #! quotation to the callback continuation.
  [ , callback-cc get , \ call , ] make-list ;
  
: quot-href ( text quot -- )
  #! Write to standard output an HTML HREF where the href,
  #! when referenced, will call the quotation and then return
  #! back to the most recent 'show' call (via the callback-cc).
  #! The text of the link will be the 'text' argument on the 
  #! stack.
  <a href= callback-quot expirable register-continuation id>url a> write </a> ;

: init-session-namespace ( -- )
  #! Setup the initial session namespace. Currently this only
  #! sets the redirect flag so that the initial request of the
  #! responder will not do a post-refresh-get style redirect.
  #! This prevents the initial request to a responder from redirecting
  #! to an URL with a continuation id. This word must be run from
  #! within the session namespace.
  f post-refresh-get? set ;

: install-cont-responder ( name quot -- )
  #! Install a cont-responder with the given name
  #! that will initially run the given quotation.
  #!
  #! Convert the quotation so it is run within a session namespace
  #! and that namespace is initialized first.
  \ init-session-namespace swons [ , \ with-scope , ] make-list
  <responder> [ 
     [ cont-get/post-responder ] "get" set 
     [ cont-get/post-responder ] "post" set 
     over "responder-name" set
     over "responder" set
     reset-continuation-table 
     permanent register-continuation root-continuation set 
   ] extend swap "httpd-responders" get set-hash ;

: responder-items ( name -- items )
  #! Return the table of continuation items for a given responder. 
  #! Useful for debugging.
  "httpd-responders" get hash [ continuation-table ] bind ;


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
       <a href= a> "OK" write </a>
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
    <tr valign= "top" tr> [ <td> call </td> ] each </tr>
  </table> ;

: button ( label -- )
  #! Output an HTML submit button with the given label.
  <input type= "submit" value= input/> ;

: with-simple-html-output ( quot -- )
  #! Run the quotation inside an HTML stream wrapped
  #! around stdio.
  <pre> 
    stdio get <html-stream> [
      call
    ] with-stream
  </pre> ;

