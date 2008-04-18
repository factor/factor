! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces sequences definitions io.files
inspector continuations tools.crossref tools.vocabs 
io prettyprint source-files assocs vocabs vocabs.loader
io.backend splitting accessors ;
IN: editors

TUPLE: no-edit-hook ;

M: no-edit-hook summary
    drop "You must load one of the below vocabularies before using editor integration:" ;

SYMBOL: edit-hook

: available-editors ( -- seq )
    "editors" all-child-vocabs-seq [ vocab-name ] map ;

: editor-restarts ( -- alist )
    available-editors
    [ [ "Load " prepend ] keep ] { } map>assoc ;

: no-edit-hook ( -- )
    \ no-edit-hook new
    editor-restarts throw-restarts
    require ;

: edit-location ( file line -- )
    >r (normalize-path) r>
    edit-hook get [ call ] [ no-edit-hook edit-location ] if* ;

: edit ( defspec -- )
    where [ first2 edit-location ] when* ;

: edit-vocab ( name -- )
    vocab-source-path 1 edit-location ;

GENERIC: find-parse-error ( error -- error' )

M: parse-error find-parse-error
    dup error>> find-parse-error [ ] [ ] ?if ;

M: condition find-parse-error
    error>> find-parse-error ;

M: object find-parse-error
    drop f ;

: :edit ( -- )
    error get find-parse-error [
        [ file>> path>> ] [ line>> ] bi edit-location
    ] when* ;

: fix ( word -- )
    [ "Fixing " write pprint " and all usages..." print nl ]
    [ [ usage ] keep prefix ] bi
    [
        [ "Editing " write . ]
        [
            "RETURN moves on to the next usage, C+d stops." print
            flush
            edit
            readln
        ] bi
    ] all? drop ;
