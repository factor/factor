! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces sequences definitions io.files
inspector continuations tuples tools.crossref io prettyprint
source-files ;
IN: editors

TUPLE: no-edit-hook ;

M: no-edit-hook summary drop "No edit hook is set" ;

SYMBOL: edit-hook

: edit-location ( file line -- )
    >r ?resource-path r>
    edit-hook get dup [
        \ no-edit-hook construct-empty throw
    ] if ;

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
