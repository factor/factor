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
! A Smalltalk-like browser that runs in the httpd server using
! cont-responder facilities.
!
IN: browser-responder
USING: html cont-responder kernel io namespaces words lists prettyprint 
       memory sequences ;

: option ( current text -- )
  #! Output the HTML option tag for the given text. If
  #! it is equal to the current string, make the option selected.
  2dup = [
    "<option selected>" write
  ] [
    "<option>" write
  ] ifte      
  chars>entities write 
  "</option>\n" write drop ;

: vocab-list ( vocab -- )
  #! Write out the HTML for the list of vocabularies. Make the currently 
  #! selected vocab be 'vocab'.
  <select name= "vocab" style= "width: 200" size= "20" onchange= "document.forms.main.submit()" select> 
    vocabs [ over swap option ] each drop
  </select> ;

: word-list ( vocab word -- )
  #! Write out the HTML for the list of words in a vocabulary. Make the 'word' item
  #! the currently selected option.
  <select name= "word" style= "width: 200" size= "20" onchange= "document.forms.main.submit()" select> 
    swap words [ word-name over swap option ] each drop
  </select> ;

: find-word ( vocab string -- word )
  #! Given the name of a word, find it in the given vocab. Return the
  #! word object itself if successfull, otherwise return false.
  swap unit search ;

: word-source ( vocab word -- )
  #! Write the source for the given word from the vocab as HTML.
  find-word [
    [ see ] with-simple-html-output
  ] when* ;

: vm-statistics ( -- )
  #! Display statistics about the vm.
  <pre> room. </pre> ;

: browser-body ( vocab word -- )
  #! Write out the HTML for the body of the main browser page.
  <table width= "100%" table> 
    <tr>  
      <td> "<b>Vocabularies</b>" write </td>
      <td> "<b>Words</b>" write </td>
      <td> "<b>Source</b>" write </td>
    </tr>
    <tr>  
      <td valign= "top" style= "width: 200" td> over vocab-list </td> 
      <td valign= "top" style= "width: 200" td> 2dup word-list </td> 
      <td valign= "top" td> word-source </td> 
    </tr>
  </table>
  vm-statistics ;

: browser-title ( vocab word -- )
  #! Output the HTML title for the browser.
  <title> 
    "Factor Browser - " write 
    swap write
    " - " write
    write
  </title> ;

: browser-style ( -- )
  #! Stylesheet for browser pages
  <style>
    "A:link { text-decoration:none}\n" write
    "A:visited { text-decoration:none}\n" write
    "A:active { text-decoration:none}\n" write
    "A:hover, A.nav:hover { border: 1px solid black; text-decoration: none; margin: 0px }\n" write
    "A { margin: 1px }" write
  </style> ;

: browse ( vocab word -- )
  #! Display a Smalltalk like browser for exploring words.
  [
    <html> 
      <head> 2dup browser-title browser-style </head>
      <body> 
        <form name= "main" action= "" method= "get" form> browser-body </form>
      </body>
    </html> 
  ] show-final ;

: browser-responder ( -- )
  #! Start the Smalltalk-like browser.
  "query" get [     
     [ "vocab" swap assoc ] keep
     "word" swap assoc
  ] [
    "browser-responder" "<browser>" 
  ] ifte* browse ;
