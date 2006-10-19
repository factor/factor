! Copyright (C) 2004 Chris Double
! Copyright (C) 2004, 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: furnace:browser
USING: definitions hashtables help html httpd io kernel memory
namespaces prettyprint sequences words xml furnace arrays ;

: option ( current text -- )
    #! Output the HTML option tag for the given text. If
    #! it is equal to the current string, make the option selected.
    <option tuck = [ "selected" =selected ] when option>
        write
    </option> ;

: options ( current seq -- ) [ option ] each-with ;

: list ( current seq name -- )
    <select =name "width: 200px;" =style "20" =size
        "JavaScript:document.getElementById('main').submit();" =onchange
    select>
        options
    </select> ;

: current-vocab ( -- string )
    "vocab" query-param [ "kernel" ] unless* ;

: current-word ( -- word )
    "word" query-param "vocab" query-param lookup ;

: vocab-list ( vocab -- ) vocabs "vocab" list ;

: word-list ( word vocab -- )
    [ lookup [ word-name ] [ f ] if* ] keep
    vocab hash-keys natural-sort "word" list ;

: word-source ( -- )
    #! Write the source for the given word from the vocab as HTML.
    current-word [ see-help ] when* ;

: browser-body ( word vocab -- )
    #! Write out the HTML for the body of the main browser page.
    <table "100%" =width table> 
        <tr>
            <th> "Vocabularies" write </th>
            <th> "Words" write </th>
            <th> "Documentation" write </th>
        </tr>
        <tr>    
            <td "top" =valign "width: 200px;" =style td>
                dup vocab-list
            </td> 
            <td "top" =valign "width: 200px;" =style td>
                word-list
            </td>
            <td "top" =valign td> word-source </td> 
        </tr>
    </table> ;

: browser-title ( word vocab -- str )
    2dup lookup dup
    [ 2nip summary ] [ drop nip "IN: " swap append ] if ;

: browse ( word vocab -- )
    #! Display a Smalltalk like browser for exploring words.
    2dup browser-title [
        [
            <form "main" =id "browse" =action "get" =method form>
                browser-body
            </form>
        ] with-html-stream
    ] html-document ;

\ browse {
    { "word" }
    { "vocab" "kernel" v-default }
} define-action

"browser" "browse" "contrib/furnace" web-app

M: word browser-link-href
    dup word-name swap word-vocabulary \ browse
    3array >quotation quot-link ;
