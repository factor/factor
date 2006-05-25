! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!        this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!        this list of conditions and the following disclaimer in the documentation
!        and/or other materials provided with the distribution.
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
USING: cont-responder hashtables help html io kernel
memory namespaces prettyprint sequences words xml ;

: option ( current text -- )
    #! Output the HTML option tag for the given text. If
    #! it is equal to the current string, make the option selected.
    2dup = [
        "<option selected>" write
    ] [
        "<option>" write
    ] if            
    chars>entities write 
    "</option>\n" write drop ;

: vocab-list ( vocab -- )
    #! Write out the HTML for the list of vocabularies. Make the currently 
    #! selected vocab be 'vocab'.
    <select "vocab" =name "width: 200px; " =style "20" =size "document.forms.main.submit()" =onchange select> 
        vocabs [ over swap option ] each drop
    </select> ;

: word-list ( vocab word -- )
    #! Write out the HTML for the list of words in a vocabulary. Make the 'word' item
    #! the currently selected option.
    <select "word" =name "width: 200px; " =style "20" =size "document.forms.main.submit()" =onchange select> 
        swap words natural-sort
        [ word-name over swap option ] each drop
    </select> ;

: word-source ( vocab word -- )
    #! Write the source for the given word from the vocab as HTML.
    swap lookup [ [ help ] with-html-stream ] when* ;

: browser-body ( vocab word -- )
    #! Write out the HTML for the body of the main browser page.
    <table "100%" =width table> 
        <tr>
            <th> "Vocabularies" write </th>
            <th> "Words" write </th>
            <th> "Documentation" write </th>
        </tr>
        <tr>    
            <td "top" =valign "width: 200px;" =style td> over vocab-list </td> 
            <td "top" =valign "width: 200px;" =style td> 2dup word-list </td> 
            <td "top" =valign td> word-source </td> 
        </tr>
    </table> ;

: browser-title ( vocab word -- )
    #! Output the HTML title for the browser.
    [ "Factor Browser - " % swap % " - " % % ] "" make ;

: browse ( vocab word -- )
    #! Display a Smalltalk like browser for exploring words.
    [
        2dup browser-title dup [
            <h1> write </h1>
            <form "main" =name "" =action "get" =method form> browser-body </form>
        ] html-document
    ] show-final ;

: browser-responder ( -- )
    #! Start the Smalltalk-like browser.
    "vocab" "query" get hash [ "browser-responder" ] unless*
    "word" "query" get hash [ "browse" ] unless* browse ;
