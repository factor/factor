! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces sequences definitions io.files
inspector continuations tuples tools.crossref tools.browser 
io prettyprint source-files assocs vocabs vocabs.loader ;
IN: editors

TUPLE: no-edit-hook ;

M: no-edit-hook summary
    drop "You must load one of the below vocabularies before using editor integration:" ;

SYMBOL: edit-hook

: available-editors ( -- seq )
    "editors" all-child-vocabs
    values concat [ vocab-name ] map ;

: editor-restarts ( -- alist )
    available-editors
    [ "Load " over append swap ] { } map>assoc ;

: no-edit-hook ( -- )
    \ no-edit-hook construct-empty
    editor-restarts throw-restarts
    require ;

: edit-location ( file line -- )
    edit-hook get [
        >r >r ?resource-path r> r> call
    ] [
        no-edit-hook edit-location
    ] if* ;

: edit ( defspec -- )
    where [ first2 edit-location ] when* ;

: :edit ( -- )
    error get delegates [ parse-error? ] find-last nip [
        dup parse-error-file source-file-path ?resource-path
        swap parse-error-line edit-location
    ] when* ;

: fix ( word -- )
    "Fixing " write dup pprint " and all usages..." print nl
    dup smart-usage swap add* [
        "Editing " write dup .
        "RETURN moves on to the next usage, C+d stops." print
        flush
        edit
        readln
    ] all? drop ;
