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
USE: stdio
USE: httpd
USE: httpd-responder
USE: math
USE: random
USE: namespaces
USE: streams
USE: lists
USE: strings
USE: html
USE: kernel
USE: html
USE: logging
USE: url-encoding
USE: unparser
USE: hashtables
USE: parser
USE: prettyprint
USE: inspector

: expiry-timeout ( -- timeout-seconds )
  #! Number of seconds to timeout continuations in
  #! continuation table. This value will need to be
  #! tuned. I leave it at 24 hours but it can be
  #! higher/lower as needed. Default to 12 hours for
  #! testing.
  12 3600 * ;

: redirect-enabled? 
  #! Set to true if you want the post-redirect-get pattern
  #! implemented. See the redirect-to-here word for details.
  t ;

: get-random-id ( -- id ) 
  #! Generate a random id to use for continuation URL's
  [ 32 [ random-digit unparse , ] times ] make-string str>number 36 >base ;

: continuation-table ( -- <namespace> ) 
  #! Return the global table of continuations
  "continuation-table" get ;
    
: reset-continuation-table ( -- ) 
  #! Create the initial global table
  <namespace> "continuation-table" set ;

: continuation-item ( expire? quot id -- <item> )
  #! A continuation item is the actual item stored
  #! in the continuation table. It contains the id,
  #! quotation/continuation, time added, etc. If
  #! expire? is true then the continuation will
  #! be expired after a certain amount of time.
  <namespace> [
    "id" set
    "quot" set
    "expire?" set
    millis "time-added" set
  ] extend ;

: seconds>millis ( seconds -- millis )
  #! Convert a number of seconds to milliseconds
  1000 * ;

: expired? ( timeout-seconds <item> -- bool )
  #! Return true if the continuation item is expirable
  #! and has expired (ie. was added to the table more than
  #! timeout milliseconds ago).
  [ seconds>millis "time-added" get + millis - 0 < 
    "expire?" get and 
  ] bind ;

: continuation-items ( -- alist )
  #! Return an alist of all continuation items in the continuation
  #! table with the car as the id and the cdr as the item.
  continuation-table hash>alist ;

: expire-continuations ( timeout-seconds -- )
  #! Expire all continuations in the continuation table
  #! if they are 'timeout-seconds' old (ie. were added
  #! more than 'timeout-seconds' ago.
  continuation-items [ cdr dupd expired? not ] subset nip
  alist>hash "continuation-table" set ;

: register-continuation ( expire? quot -- id ) 
  #! Store a continuation in the table and associate it with
  #! a random id. That continuation will be expired after
  #! a certain period of time if 'expire?' is true.  
  continuation-table [ 
    get-random-id -rot pick continuation-item over set 
  ] bind ;
  
: append* ( lists -- list )
  #! Given a list of lists, append the lists together
  #! and return the concatenated list.
  f swap [ append ] each ;
  
: register-continuation* ( expire? quots -- id ) 
  #! Like register-continuation but registers a quotation 
  #! that will call all quotations in the list, in the order given.
  append* register-continuation ;

: get-continuation-item ( id -- <item> )
  #! Get the continuation item associated with the id.
  continuation-table [ get ] bind ;

: id>url ( id -- string )
  #! Convert the continuation id to an URL suitable for
  #! embedding in an HREF or other HTML.
  url-encode "?id=" swap cat2 ;

DEFER: show 

: expired-page-handler ( alist -- )
  #! Display a page has expired message.
  #! TODO: Need to handle this better to enable
  #!       returning back to root continuation.
  drop
  [ 
    drop
    <html>                
      <body> 
       <p> "This page has expired." write  </p> 
      </body>
    </html> 
  ] show drop ;

: get-registered-continuation ( id -- cont ) 
  #! Return the continuation or quotation 
  #! associated with the given id.  
  #! TODO: handle expired pages better.
  expiry-timeout expire-continuations
  get-continuation-item dup [
    [ "quot" get ] bind 
  ] [
   drop [ expired-page-handler ]
  ] ifte ;

: resume-continuation ( value id  -- ) 
  #! Call the continuation associated with the given id,
  #! with 'value' on the top of the stack.
  get-registered-continuation call ;

: exit-continuation ( -- exit ) 
  #! Get the current exit continuation
  "exit" get ;

: call-exit-continuation ( value -- ) 
  #! Call the exit continuation, passing it the given value on the
  #! top of the stack.
  "exit" get call ;

: with-exit-continuation ( quot -- ) 
  #! Call the quotation with the variable "exit" bound such that when
  #! the exit continuation is called, computation will resume from the
  #! end of this 'with-exit-continuation' call, with the value passed
  #! to the exit continuation on the top of the stack.
  [ "exit" set call f call-exit-continuation ] callcc1 nip ;

: store-callback-cc ( -- )
  #! Store the current continuation in the variable 'callback-cc' 
  #! so it can be returned to later by callbacks. Note that it
  #! recalls itself when the continuation is called to ensure that
  #! it resets its value back to the most recent show call.
  [  ( 0 -- )
    [ ( 0 1 -- )
      "callback-cc" set ( 0 -- )
      call 
    ] callcc1 ( 0 [ ] == )
    nip
    call 
    store-callback-cc
  ] callcc0 ;

: with-string-stream ( quot -- string ) 
  #! Call the quotation with standard output bound to a string output
  #! stream. Return the string on exit.
  1024 <string-output> dup >r swap with-stream r> stream>str ;

: forward-to-url ( url -- )
  #! When executed inside a 'show' call, this will force a
  #! HTTP 302 to occur to instruct the browser to forward to
  #! the request URL.
  [ 
    "HTTP/1.1 302 Document Moved\nLocation: " , ,
    "\nContent-Length: 0\nContent-Type: text/plan\n\n" , 
  ] make-string call-exit-continuation ;

: redirect-to-here ( -- )
  #! Force a redirect to the client browser so that the browser
  #! goes to the current point in the code. This forces an URL
  #! change on the browser so that refreshing that URL will
  #! immediately run from this code point. This prevents the 
  #! "this request will issue a POST" warning from the browser
  #! and prevents re-running the previous POST logic. This is
  #! known as the 'post-refresh-get' pattern.
  "disable-initial-redirect?" get [
    "disable-initial-redirect?" f put 
  ] [
    [ 
      t swap register-continuation 
      [ "HTTP/1.1 302 Document Moved\nLocation: " , id>url , "\n" , 
        "Content-Length: 0\nContent-Type: text/plain\n\n" , ] make-string
      call-exit-continuation 
    ] callcc1 drop 
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
  store-callback-cc
  redirect-enabled? [ redirect-to-here ] when
  [ 
    t swap register-continuation id>url swap 
    [ serving-html ] car swons with-string-stream
    call-exit-continuation 
  ] callcc1 
  nip ;


: cont-get-responder ( id-or-f -- ) 
  #! httpd responder that retrieves a continuation and calls it.
  drop
  "id" "query" get assoc
  dup f-or-"" [
    #! No continuation id given
    drop "root-continuation" get dup [
      #! Use the root continuation
      [ f swap resume-continuation ] with-exit-continuation
    ] [
      #! No root continuation either
      drop [ f expired-page-handler ] with-exit-continuation
    ] ifte
  ] [
    #! Use the given continuation  
    [ f swap resume-continuation ] with-exit-continuation
  ] ifte 
  [ write flush ] when* drop ;

: cont-post-responder ( id -- )    
  #! httpd responder that retrieves a continuation for the given
  #! id and calls it with the POST data as a hashtable on the top
  #! of the stack.
  [ 
    drop
    "response" get alist>hash 
    "id" "query" get assoc resume-continuation 
  ] with-exit-continuation
  print drop ;

: callback-quot ( quot -- quot )
  #! Convert the given quotation so it works as a callback
  #! by returning a quotation that will pass the original 
  #! quotation to the callback continuation.
  unit "callback-cc" get [ call ] cons append ;
  
: quot-href ( text quot -- )
  #! Write to standard output an HTML HREF where the href,
  #! when referenced, will call the quotation and then return
  #! back to the most recent 'show' call (via the callback-cc).
  #! The text of the link will be the 'text' argument on the 
  #! stack.
  <a href= callback-quot t swap register-continuation id>url a> write </a> ;

: with-new-session ( quot -- )
  #! Each cont-responder is bound inside their own
  #! namespace for storing session state. Run the given
  #! quotation inside a new namespace for this purpose.
  <namespace> swap bind ;

: init-session-namespace ( -- )
  #! Setup the initial session namespace. Currently this only
  #! copies the global value of whether the initial redirect
  #! will be disabled. It assumes the session namespace is
  #! topmost on the namespace stack.
  "disable-initial-redirect?" get "disable-initial-redirect?" set ;

: install-cont-responder ( name quot -- )
  #! Install a cont-responder with the given name
  #! that will initially run the given quotation.
  #!
  #! Convert the quotation so it is run within a session namespace
  #! and that namespace is initialized first.
  [ init-session-namespace ] swap append unit [ with-new-session ] append
  "httpd-responders" get [ 
     <responder> [ 
       [ cont-get-responder ] "get" set 
       [ cont-post-responder ] "post" set 
       over "responder-name" set
       over "responder" set
       reset-continuation-table 
       "disable-initial-redirect?" t put 
     ] extend dup >r rot set 
     r> [     
       f swap register-continuation "root-continuation" set 
     ] bind
  ] bind ;

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

