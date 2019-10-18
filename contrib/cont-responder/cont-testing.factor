! cont-testing
!
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
! Words for testing continuation based responders at the console
! prompt.
!
! To start a 'test' session use '<cont-test-state>' to push the
! continuation responder state on the stack.
!
! Then use 'test-cont-function' to call a continuation responder word.
! All output will go to the console. From this output you will see
! links that you can 'visit' by doing a simulated click. Use the
! 'test-cont-click' function by passing the state, the 'id' of the click
! continuation, and 'f' or a hashtable containing the post data. The output
! from this will be displayed.
!
! eg.
! <cont-test-state> [ test-cont-responder ] test-cont-function
!   => HTTP/1.1 302 Document Moved
!      Location: ?id=8506502852110820
!      Content-Length: 0
!      Content-Type: text/plain
!
! "8506502852110820" f test-cont-click
!   => HTTP/1.0 200 Document follows
!      Content-Type: text/html
!
!      <html><head><title>Page one</title></head><body>
!      <h1>Page one</h1><a href='?id=5431597582800278'>Next</a>
!      </body></html>
!
! "5431597582800278" f test-cont-click
!   => HTTP/1.1 302 Document Moved
!      Location: ?id=7944183606904129
!      Content-Length: 0
!      Content-Type: text/plain
!
! "7944183606904129" f test-cont-click
!   => HTTP/1.0 200 Document follows
!      Content-Type: text/html
!
!      <html><head><title>Enter your name</title></head>
!      <body><h1>Enter your name</h1>
!      <form method='post' action='?id=8503790719833723'>
!      Name: <input type='text' name='name'size='20'>
!      <input type='submit' value='Ok'>
!      </form></body></html>
!
! "8503790719833723" [ [[ "name" "Chris" ]] ] alist>hash test-cont-click
!   => HTTP/1.1 302 Document Moved
!      Location: ?id=8879727708050260
!      Content-Length: 0
!      Content-Type: text/plain
!
! "8879727708050260" f test-cont-click
!   => HTTP/1.0 200 Document follows
!      Content-Type: text/html
!
!      <html><head><title>Hello Chris</title></head>
!      <body><h1>Hello Chris</h1>
!      <a href='?id=0937854264503953'>Next</a>
!      </body></html>
! 
! etc.
IN: cont-responder
USE: namespaces
USE: kernel
USE: combinators
USE: io

: <cont-test-state> ( -- <state> )
  #! Create a namespace holding data required
  #! for testing continuation based responder functions
  #! at the interpreter console.
  <namespace> [
    reset-continuation-table
    init-session-namespace    
  ] extend ;

: test-cont-function ( <state> quot -- <state> )
  #! Call a continuation responder function with required
  #! plumbing set up so output is displayed to the console.
  swap dup >r [
    [ call ] with-exit-continuation
  ] bind write drop r> ;

: test-cont-click ( <state> id data -- <state> )
  #! Test function to 'click' a continuation with the given
  #! 'id' and post data. Display the results on the console.
  rot dup >r [
    [ swap resume-continuation ] with-exit-continuation 
  ] bind write 2drop r> ;
