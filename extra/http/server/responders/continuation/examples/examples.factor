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
!
! Simple test applications
USING: hashtables html kernel io html html.elements strings math assocs quotations
http.server.responders.continuation namespaces prettyprint sequences ;

IN: http.server.responders.continuation.examples

: display-page ( title -- ) 
  #! Display a page with some text to test the cont-responder.
  #! The page has a link to the 'next' continuation.
  [ 
    <h1> over write </h1>
    swap [ 
      <a =href a> "Next" write </a>
    ] simple-html-document 
  ] show 2drop ;

: display-get-name-page ( -- name )
  #! Display a page prompting for input of a name and return that name.
  [ 
    "Enter your name" [
      <h1> swap write </h1>
      <form "post" =method =action form> 
        "Name: " write
        <input "text" =type "name" =name "20" =size input/>
        <input "submit" =type "Ok" =value input/>
      </form>
    ] simple-html-document
  ] show "name" swap at ;

: test-cont-responder ( -- )
  #! Test the cont-responder responder by displaying a few pages in a row.
  "Page one" display-page 
  "Hello " display-get-name-page append display-page
  "Page three" display-page ;

: test-cont-responder2 ( -- )
  #! Test the cont-responder responder by displaying a few pages in a loop.
  [ "one" "two" "three" "four" ] [ display-page ]  each 
  "Done!" display-page  ;

: test-cont-responder3 ( -- )
  #! Test the quot-href word by displaying a menu of the current
  #! test words. Note that we use show-final as we don't link to a 'next' page.
  [ 
    "Menu" [ 
      <h1> "Menu" write </h1>
      <ol> 
        <li> "Test responder1" [ test-cont-responder ] quot-href </li>
        <li> "Test responder2" [ test-cont-responder2 ] quot-href </li>
      </ol>
    ] simple-html-document 
  ] show-final ;

: counter-example ( count -- )
  #! Display a counter which can be incremented or decremented
  #! using anchors.
  #!
  #! Don't need the original alist
  [ 
    #! And we don't need the 'url' argument
    drop         
    "Counter: " over unparse append [ 
      dup <h2> unparse write </h2>
      "++" over 1quotation [ f ] swap append [ 1 + counter-example ] append quot-href
      "--" over 1quotation [ f ] swap append [ 1 - counter-example ] append quot-href
      drop
    ] simple-html-document 
  ] show drop ;

: counter-example2 ( -- )
  #! Display a counter which can be incremented or decremented
  #! using anchors.
  #!
  0 "counter" set
  [ 
    #! We don't need the 'url' argument
    drop   
    "Counter: " "counter" get unparse append [ 
      <h2> "counter" get unparse write </h2>
      "++" [ "counter" get 1 + "counter" set ] quot-href
      "--" [ "counter" get 1 - "counter" set ] quot-href
    ] simple-html-document 
  ] show 
  drop ;

! Install the examples
"counter1" [ drop 0 counter-example ] install-cont-responder
"counter2" [ drop counter-example2 ] install-cont-responder
"test1" [ test-cont-responder ] install-cont-responder
"test2" [ drop test-cont-responder2 ] install-cont-responder
"test3" [ drop test-cont-responder3 ] install-cont-responder
