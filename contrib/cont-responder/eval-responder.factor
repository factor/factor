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
USE: html
USE: cont-responder
USE: kernel
USE: namespaces
USE: io
USE: parser
USE: lists
USE: errors
USE: strings
USE: live-updater
USE: prettyprint
USE: words
USE: vectors
USE: sequences
USE: hashtables

: <evaluator> ( stack msg history -- )
  #! Create an 'evaluator' object that holds
  #! the current stack, output and history for
  #! do-eval.
  [
    "history" set
    "output" set
    "stack" set
  ] make-hash ;

: display-eval-form ( url -- )
  #! Display the components for allowing entry of 
  #! factor words to be evaluated.
  <form "main" =name "post" =method =action form>     
    [
      [
        <textarea "eval" =name "10" =rows "40" =cols textarea> 
          "" write 
        </textarea>
      ]
      [
        <input "submit" =type "Evaluate" =value "e" =accesskey input/>  
      ]
    ] vertical-layout
  </form> 
  "<script language='javascript'>document.forms.main.eval.focus()</script>" write ;

: escape-quotes ( string -- string )
  #! Replace occurrences of single quotes with
  #! backslash quote.
  [
      [ dup H{ { CHAR: ' "\\'" } { CHAR: " "\\\"" } } hash [ % ] [ % ] ?if ] each
  ] "" make ;
 
: make-eval-javascript ( string -- string )
  #! Give a string return some javascript that when
  #! executed will set the eval textarea to that string.
  [ "document.forms.main.eval.value=\"" % escape-quotes % "\"" % ] "" make ;
: write-eval-link ( string -- )
  #! Given text to evaluate, create an A HREF link which when
  #! clicked sets the eval textarea to that value.
  <a "#" =href dup make-eval-javascript =onclick a> write </a> ;

: display-stack ( list -- )
  #! Write out html to display the stack.
  <table "1" =border table> 
    <tr> <th> "Callstack" write </th> </tr>
    [ <tr> <td> [ unparse write ] string-out write-eval-link </td> </tr> ] each
  </table> ;

: display-clear-history-link ( -- )
  #! Write out html to display a link that will clear
  #! the history list.
  " (" write  
  "Clear" [ [ ] "history" set ] quot-href
  ")" write ;

: display-history ( list -- )
  #! Write out html to display the history.
  <table "1" =border table> 
    <tr> <th> "History" write display-clear-history-link </th> </tr>
    [ <tr> <td> write-eval-link </td> </tr> ] each
  </table> ;

: usages. ( word -- )
  #! Write to output the words that use the given word, one
  #! per line.
  usages [ . ] each ;

: html-for-word-source ( word-string -- )
  #! Return an html fragment dispaying the source
  #! of the given word.
  dup dup
  [
    "browser" "responder" set
    <table "1" =border table> 
      <tr> <th "2" =colspan th> "Source" write </th> </tr>
      <tr> <td "2" =colspan td> [ [ parse ] catch [ "No such word" write ] [ car see ] if ] with-simple-html-output </td> </tr>
      <tr> <th> "Apropos" write </th> <th> "Usages" write </th> </tr>
      <tr> <td "top" =valign td> [ apropos ] with-simple-html-output </td> 
           <td "top" =valign td> [ [ parse ] catch [ "No such word" write ] [ car usages. ] if ] with-simple-html-output </td>
      </tr>
    </table>
  ] make-hash ;

: display-word-see-form ( url -- )
  #! Write out the html for code that accepts
  #! the name of a word, and displays the source
  #! code of that word.
  [
    [ 
      "Enter the name of a word: " write
      "see" [ html-for-word-source ] live-search
    ]
    [
      <div "see" =id div> "" write </div>
    ]
  ] vertical-layout ;

: display-last-output ( string -- )
  #! Write out html to display the last output.
  <table "1" =border table> 
    <tr> <th> "Last Output" write </th> </tr>
    <tr> <td> <pre> write </pre> </td> </tr>
  </table> ;
  

: get-expr-to-eval (  -- string )
  #! Show a page to the user requesting the form to be
  #! evaluated. Return the form as a string. Assumes
  #! an evaluator is on the namestack.
  [ 
    <html> 
      <head> 
        <title> "Factor Evaluator" write </title>
        include-live-updater-js
      </head>        
      <body> 
        "Use Alt+E to evaluate, or press 'Evaluate'" paragraph
        [
          [ display-eval-form ]
          [ "stack" get display-stack ]
          [ "history" get display-history ]
        ] horizontal-layout
	display-word-see-form
        "output" get display-last-output
      </body>
    </html>
  ] show [
    "eval" get
  ] bind ;
   
: >pop> dup pop* ;

: infra ( list quot -- list )
  #! Call the quotation using 'list' as the datastack
  #! return the result datastack as a list.
  datastack >r    
  swap >vector tuck push 
  set-datastack call datastack >list
  r> >pop> >pop> tuck push set-datastack ;

: do-eval ( list string -- list )
  #! Evaluate the expression in 'string' using 'list' as
  #! the datastack. Return the resulting stack as a list.
  parse infra ;

: do-eval-to-string ( list string -- list string )
  #! Evaluate expression using 'list' as the current callstack.
  #! All output should go to a string which is returned on the
  #! callstack along with the resulting datastack as a list.
  [
    "browser" "responder" set
    1024 <sbuf> dup >r <html-stream> [
      do-eval
    ] with-stream r> >string
  ] with-scope ;

: forever ( quot -- )
  #! The code is evaluated in an infinite loop. Typically, a
  #! continuation is used to escape the infinite loop.
  #!
  #! This combinator will not compile.
  dup slip forever ;

: cons@ ( value name -- )
  #! Get the value of the variable named by 'name'
  #! from the current namespace and cons 'value' to its
  #! current value.
  dup get rot swons swap set ;

: run-eval-requester ( evaluator -- )
  #! Enter a loop request an expression to
  #! evaluate, and displaying the results. 
  [
    [
      get-expr-to-eval dup "history" cons@
      "stack" get swap do-eval-to-string 
      "output" set "stack" set
    ] forever 
  ] bind ;
  
: eval-responder ( evaluator -- )
  #! Run an eval-responder using the given evaluation details.
  [
    [ 
      run-eval-requester 
    ] catch 
    dup [ show-message-page ] [ drop ] if
  ] forever ;

! "eval" [ [ ] "None" [ ] <evaluator> eval-responder ] install-cont-responder

