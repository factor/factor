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
! General purpose words for display pages using the continuation 
! based responder.
IN: cont-utils
USE: html
USE: cont-responder
USE: lists
USE: stdio
USE: stack
USE: namespaces
USE: html
USE: combinators

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
    "stdio" get <html-stream> [
      call
    ] with-stream
  </pre> ;
