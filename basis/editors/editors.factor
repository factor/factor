! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser lexer kernel namespaces sequences definitions
io.files io.backend io.pathnames io summary continuations
tools.crossref vocabs.hierarchy prettyprint source-files
source-files.errors assocs vocabs vocabs.loader splitting
accessors debugger prettyprint help.topics ;
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
    [ (normalize-path) ] dip edit-hook get-global
    [ call( file line -- ) ] [ no-edit-hook edit-location ] if* ;

ERROR: cannot-find-source definition ;

M: cannot-find-source error.
    "Cannot find source for ``" write
    definition>> pprint-short
    "''" print ;

: edit ( defspec -- )
    dup where
    [ first2 edit-location ]
    [ dup word-link? [ name>> edit ] [ cannot-find-source ] if ]
    ?if ;

: edit-vocab ( name -- )
    >vocab-link edit ;

GENERIC: error-file ( error -- file )

GENERIC: error-line ( error -- line )

M: lexer-error error-file
    error>> error-file ;

M: lexer-error error-line
    [ error>> error-line ] [ line>> ] bi or ;

M: source-file-error error-file
    [ error>> error-file ] [ file>> ] bi or ;

M: source-file-error error-line
    error>> error-line ;

M: condition error-file
    error>> error-file ;

M: condition error-line
    error>> error-line ;

M: object error-file
    drop f ;

M: object error-line
    drop f ;

: (:edit) ( error -- )
    [ error-file ] [ error-line ] bi
    2dup and [ edit-location ] [ 2drop ] if ;

: :edit ( -- )
    error get (:edit) ;

: edit-error ( error -- )
    [ file>> ] [ line#>> ] bi 2dup and [ edit-location ] [ 2drop ] if ;

: edit-each ( seq -- )
    [
        [ "Editing " write . ]
        [
            "RETURN moves on to the next usage, C+d stops." print
            flush
            edit
            readln
        ] bi
    ] all? drop ;

: fix ( word -- )
    [ "Fixing " write pprint " and all usages..." print nl ]
    [ [ smart-usage ] keep prefix ] bi
    edit-each ;
