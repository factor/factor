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
! An Smalltalk-link browser that runs in the httpd server using
! cont-responder facilities.
!
IN: browser
USE: cont-html
USE: cont-responder
USE: cont-utils
USE: stack
USE: stdio
USE: combinators
USE: namespaces
USE: words
USE: lists
USE: streams
USE: strings
USE: inspector
USE: kernel
USE: prettyprint
USE: words
USE: html
USE: parser
USE: errors
USE: unparser
USE: logging

: <browser> ( allow-edit? vocab word -- )
  #! An object for storing the current browser
  #! user interface state.
  <namespace> [
    "current-word" set
    "current-vocab" set
    "allow-edit?" set
  ] extend ;

: write-vocab-list ( -- )
  #! Write out the HTML for the list of vocabularies
  <select name= "vocabs" style= "width: 200" size= "20" onchange= "document.forms.main.submit()" select> 
    vocabs [ 
      dup "current-vocab" get [ "" ] unless* = [
        "<option selected>" write
      ] [
        "<option>" write
      ] ifte 
      chars>entities write 
      "</option>\n" write     
    ] each
  </select> ;

: write-word-list ( vocab -- )
  #! Write out the HTML for the list of words in a vocabulary.
  <select name= "words" style= "width: 200" size= "20" onchange= "document.forms.main.submit()" select> 
    words [ 
      word-name dup "current-word" get [ "" ] unless* str-compare 0 = [
      "<option selected>" write
     ] [
        "<option>" write
     ] ifte 
     chars>entities write 
     "</option>\n" write     
   ] each
  </select> ;

: write-editable-word-source ( vocab word -- )
  #! Write the source in a manner allowing it to be edited.
  <textarea name= "eval" rows= "30" cols= "80" textarea> 
    1024 <string-output-stream> dup >r [
      >r words r> swap [ over swap dup word-name rot = [ see ] [ drop ] ifte ] each drop    
    ] with-stream r> stream>str chars>entities write
  </textarea> <br/>
  "Accept" button ;

: write-word-source ( vocab word -- )
  #! Write the source for the given word from the vocab as HTML.
  <namespace> [
    "responder" "inspect" put
    "allow-edit?" get [ "Edit" [ "edit-state" t put ] quot-href <br/> ] when
    "edit-state" get [
      write-editable-word-source 
    ] [
      [ 
        >r words r> swap [ over swap dup word-name rot = [ see ] [ drop ] ifte ] each drop
      ] with-simple-html-output
    ] ifte
  ] bind drop ;

: write-vm-statistics ( -- )
  #! Display statistics about the JVM in use.
  room swap unparse >r unparse r> 
  <table> 
    <tr>  
      <td> "Free Memory" write </td>
      <td> write </td> 
    </tr>
    <tr> 
      <td> "Total Memory" write </td>
      <td> write </td> 
    </tr>
  </table> ;

: write-browser-body ( -- )
  #! Write out the HTML for the body of the main browser page.
  <table width= "100%" table> 
    <tr>  
      <td> "<b>Vocabularies</b>" write </td>
      <td> "<b>Words</b>" write </td>
      <td> "<b>Source</b>" write </td>
    </tr>
    <tr>  
      <td valign= "top" style= "width: 200" td> write-vocab-list </td> 
      <td valign= "top" style= "width: 200" td> "current-vocab" get write-word-list </td> 
      <td valign= "top" td> "current-vocab" get "current-word" get write-word-source </td> 
    </tr>
  </table>
  write-vm-statistics ;

: flatten ( tree - list ) 
  #! Flatten a tree into a list.
  dup f = [  
  ] [ 
    dup cons? [ 
      dup car flatten swap cdr flatten append 
    ] [ 
      [ ] cons 
    ] ifte 
  ] ifte ;

: word-uses ( word -- list )
  #! Return a list of vocabularies that the given word uses.
  worddef>list flatten [ word? ] subset [
    word-vocabulary
  ] map ;

: vocabulary-uses ( vocab -- list )
  #! Return a list of vocabularies that all words in a vocabulary
  #! uses.
  <namespace> [
    "result" f put
    words [
      word-uses [
        "result" unique@
      ] each
    ] each 
    "result" get
  ] bind ;

: build-eval-string ( vocab to-eval -- string )
  #! Build a string that can evaluate the string 'to-eval'
  #! by first doing an 'IN: vocab' and a 'USE:' of all
  #! necessary vocabs for existing words in that vocab.
  <% >r "IN: " % dup % "\n" %
     vocabulary-uses [ "USE: " % % "\n" % ] each
     r> % "\n" % %> ;

: show-parse-error ( error -- )
  #! Show an error page describing the parse error.
  [
    <html> 
      <head> <title> "Parse error" write </title> </head>
      <body>  
        swap [ write ] with-simple-html-output
        <a href= a> "Ok" write </a>
      </body>
    </html>
  ] show drop drop ;

: eval-string ( vocab to-eval -- )
  #! Evaluate the 'to-eval' within the given vocabulary.
  build-eval-string [
    parse call
  ] [
    [
      show-parse-error
      drop
    ] when*
  ] catch ;

: browse ( <browser> -- )
  #! Display a Smalltalk like browser for exploring/modifying words.
  [
    [
      [
        <html> 
          <head> 
            <title> "Factor Browser" write </title>
          </head>
          <body> 
            <form name= "main" action= method= "post" form> 
              write-browser-body 
            </form>
          </body>
        </html> 
      ] show [
        "allow-edit?" get [ 
          "eval" get [ 
             "eval" f put
             "Editing has been disabled." show-message-page 
          ] when
        ] unless
        "allow-edit?" get "allow-edit?" set
      ] extend
    ] bind [
      "allow-edit?" get
      "vocabs" get
      "words" get
      "eval" get dup [ "vocabs" get swap eval-string ] [ drop ] ifte
    ] bind <browser>
  ] forever ;

: browser-responder ( allow-edit? -- )
  #! Start the Smalltalk-like browser.
  "browser" f <browser> browse ;

"browser" [ f browser-responder ] install-cont-responder
