! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: browser-responder
USING: hashtables help html httpd io kernel memory namespaces
prettyprint sequences words xml ;

: option ( current text -- )
    #! Output the HTML option tag for the given text. If
    #! it is equal to the current string, make the option selected.
    <option tuck = [ "yes" =selected ] when option>
        chars>entities write
    </option> ;

: options ( current seq -- ) [ option ] each-with ;

: list ( current seq name -- )
    <select =name "width: 200px;" =style "20" =size "document.forms.main.submit()" =onchange select>
        options
    </select> ;

: current-vocab ( -- string )
    "vocab" query-param [ "kernel" ] unless* ;

: current-word ( -- word )
    "word" query-param "vocab" query-param lookup ;

: vocab-list ( -- )
    current-vocab vocabs "vocab" list ;

: word-list ( -- )
    current-word [ word-name ] [ f ] if*
    current-vocab vocab hash-keys natural-sort "word" list ;

: word-source ( -- )
    #! Write the source for the given word from the vocab as HTML.
    current-word [ [ see-help ] with-html-stream ] when* ;

: browser-body ( -- )
    #! Write out the HTML for the body of the main browser page.
    <table "100%" =width table> 
        <tr>
            <th> "Vocabularies" write </th>
            <th> "Words" write </th>
            <th> "Documentation" write </th>
        </tr>
        <tr>    
            <td "top" =valign "width: 200px;" =style td>
                vocab-list
            </td> 
            <td "top" =valign "width: 200px;" =style td>
                word-list
            </td>
            <td "top" =valign td> word-source </td> 
        </tr>
    </table> ;

: browser-title ( -- )
    current-word
    [ synopsis ] [ "IN: " current-vocab append ] if* ;

: browser-responder ( -- )
    #! Display a Smalltalk like browser for exploring words.
    serving-html browser-title dup [
        <h1> write </h1>
        <form "main" =name "" =action "get" =method form>
            browser-body
        </form>
    ] html-document ;
