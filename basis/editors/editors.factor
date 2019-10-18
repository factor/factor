! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations debugger definitions
help.topics io io.backend io.files io.launcher io.pathnames
kernel lexer math namespaces parser prettyprint sequences
source-files source-files.errors splitting strings summary
tools.crossref vocabs vocabs.files vocabs.hierarchy
vocabs.loader vocabs.metadata calendar threads words ;
FROM: vocabs => vocab-name >vocab-link ;
IN: editors

SYMBOL: editor-class

: available-editors ( -- seq )
    "editors" child-vocab-names ;

: editor-restarts ( -- alist )
    available-editors
    [ [ "Load " prepend ] keep ] { } map>assoc ;

HOOK: editor-command editor-class ( file line -- command )

M: f editor-command
    "Select an editor" editor-restarts throw-restarts require
    editor-command ;

HOOK: editor-detached? editor-class ( -- ? )
M: object editor-detached? t ;

: run-and-wait-for-editor ( command -- )
    <process>
        swap >>command 
        editor-detached? >>detached
    run-process
    300 milliseconds sleep
    dup status>> { 0 f } member?
    [ drop ] [ process-failed ] if ;

ERROR: invalid-location file line ;

: edit-location ( file line -- )
    over [ invalid-location ] unless
    [ absolute-path ] dip
    editor-command [ run-and-wait-for-editor ] when* ;

ERROR: cannot-find-source definition ;

M: cannot-find-source error.
    "Cannot find source for ``" write
    definition>> pprint-short
    "''" print ;

: edit-file ( path -- )
    0 edit-location ;

DEFER: edit

: edit-vocab ( vocab -- )
    vocab-name* >vocab-link edit ;

GENERIC: edit ( object -- )

M: object edit
    dup where [ first2 edit-location ] [ cannot-find-source ] ?if ;

M: string edit edit-vocab ;

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

GENERIC: edit-docs ( object -- )

M: object edit-docs
    vocab-name* vocab-docs-path 1 edit-location ;

M: word edit-docs
    dup "help-loc" word-prop
    [ nip first2 edit-location ]
    [ vocabulary>> edit-docs ]
    if* ;

GENERIC: edit-tests ( object -- )

M: object edit-tests
    vocab-name* vocab-tests-path 1 edit-location ;

M: word edit-tests vocabulary>> edit-tests ;

: edit-platforms ( vocab -- )
    dup vocab-platforms-path vocab-append-path 1 edit-location ;

: edit-authors ( vocab -- )
    dup vocab-authors-path vocab-append-path 1 edit-location ;

: edit-tags ( vocab -- )
    dup vocab-tags-path vocab-append-path 1 edit-location ;

: edit-summary ( vocab -- )
    dup vocab-summary-path vocab-append-path 1 edit-location ;
