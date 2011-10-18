! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations debugger definitions
help.topics io io.backend io.files io.pathnames kernel lexer
namespaces parser prettyprint sequences source-files
source-files.errors splitting strings summary tools.crossref
vocabs vocabs.files vocabs.hierarchy vocabs.loader
vocabs.metadata ;
FROM: vocabs => vocab-name >vocab-link ;
IN: editors

TUPLE: no-edit-hook ;

M: no-edit-hook summary
    drop "You must load one of the below vocabularies before using editor integration:" ;

SYMBOL: edit-hook

: available-editors ( -- seq )
    "editors" child-vocab-names ;

: editor-restarts ( -- alist )
    available-editors
    [ [ "Load " prepend ] keep ] { } map>assoc ;

: no-edit-hook ( -- )
    \ no-edit-hook new
    editor-restarts throw-restarts
    require ;

: edit-location ( file line -- )
    [ absolute-path ] dip edit-hook get-global
    [ call( file line -- ) ] [ no-edit-hook edit-location ] if* ;

ERROR: cannot-find-source definition ;

M: cannot-find-source error.
    "Cannot find source for ``" write
    definition>> pprint-short
    "''" print ;

GENERIC: edit ( object -- )

M: object edit
    dup where [ first2 edit-location ] [ cannot-find-source ] ?if ;

M: link edit name>> edit ;

M: string edit
    dup vocab [ edit ] [ cannot-find-source ] ?if ;

: edit-error ( error -- )
    [ error-file ] [ error-line ] bi
    over [ 1 or edit-location ] [ 2drop ] if ;

: :edit ( -- )
    error get edit-error ;

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

: edit-docs ( vocab -- )
    vocab-docs-path 1 edit-location ;

: edit-tests ( vocab -- )
    vocab-tests-file 1 edit-location ;

: edit-platforms ( vocab -- )
    dup vocab-platforms-path vocab-append-path 1 edit-location ;

: edit-authors ( vocab -- )
    dup vocab-authors-path vocab-append-path 1 edit-location ;

: edit-tags ( vocab -- )
    dup vocab-tags-path vocab-append-path 1 edit-location ;

: edit-summary ( vocab -- )
    dup vocab-summary-path vocab-append-path 1 edit-location ;

