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
! An httpd responder that allows executing simple definitions.
!
IN: eval-responder
USE: cont-html
USE: cont-responder
USE: cont-utils
USE: stack
USE: stdio
USE: namespaces
USE: streams
USE: parser
USE: lists
USE: errors

: display-eval-form ( url -- )
  #! Display the components for allowing entry of 
  #! factor words to be evaluated.
  <form method= "post" action= form> [
    <textarea name= "eval" textarea> [
      "" write
    ] </textarea>
    <input type= "submit" value= "Evaluate" input/>
  ] </form> ;

: display-stack ( list -- )
  #! Write out html to display 'list' as a stack.
  <table border= "1" table> [
    <tr> [ <th> [ "Callstack" write ] </th> ] </tr>
    [ <tr> [ <td> [ write ] </td> ] </tr> ] each
  ] </table> ;

: display-last-output ( string -- )
  #! Write out html to display the last output that
  #! the evaluator wrote.
  <table border= "1" table> [
    <tr> [ 
      <td> [ "Last Output" write ] </td>
      <td> [ write ] </td>
    ] </tr>
  ] </table> ;           
  
: get-expr-to-eval (  list string -- string )
  #! Show a page to the user requesting the form to be
  #! evaluated. It displays the current stack passed as 'list'
  #! and the last output given as 'string'.
  #! Return the form as a string.
  [ 
    <html> [
      <body> [
	display-eval-form
        display-last-output
        display-stack
      ] </body>
    ] </html>
  ] show [
    2drop
    "eval" get
  ] bind ;
   
: do-eval ( list string -- list )
  #! Evaluate the expression in 'string' using 'list' as
  #! the datastack. Return the resulting stack as a list.
  parse unit append restack call unstack ;

: do-eval-to-string ( list string -- list string )
  #! Evaluate expression using 'list' as the current callstack.
  #! All output should go to a string which is returned on the
  #! callstack along with the resulting datastack as a list.
  1024 <string-output-stream> dup >r [
    do-eval 
  ] with-stream r> stream>str ;

: run-eval-requester ( list string -- )
  #! Enter a loop request an expression to
  #! evaluate, and displaying the results. 
  #! 'list' will be the datastack initially
  #! user and 'string' the output from the
  #! last run.
  over >r get-expr-to-eval r> swap do-eval-to-string
  run-eval-requester ;
  
: eval-responder ( list string -- )
  #! Run an eval-responder using the list as the
  #! initial callstack.
  [ 
    run-eval-requester 
  ] [
    show-message-page
  ] catch
  eval-responder ;

"eval" [ [ ] "None" eval-responder ] install-cont-responder
