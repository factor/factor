! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar continuations debugger
definitions io io.launcher io.pathnames kernel namespaces
prettyprint sequences source-files.errors splitting strings
threads tools.crossref vocabs vocabs.files vocabs.hierarchy
vocabs.loader vocabs.metadata words ;
IN: editors

SYMBOL: editor-class

: available-editors ( -- seq )
    "editors" disk-child-vocab-names ;

: editor-restarts ( -- alist )
    available-editors
    [ [ "Load " prepend ] keep ] { } map>assoc ;

HOOK: editor-command editor-class ( file line -- command )

M: f editor-command
    "Select an editor" editor-restarts throw-restarts require
    editor-command ;

HOOK: editor-detached? editor-class ( -- ? )
M: object editor-detached? t ;

HOOK: editor-is-child? editor-class ( -- ? )
M: object editor-is-child? f ;

: run-and-wait-for-editor ( command -- )
    <process>
        swap >>command
        editor-detached? >>detached
        editor-is-child? [ +new-group+ >>group ] unless
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

<PRIVATE

: public-vocab-name ( vocab-spec -- name )
    vocab-name ".private" ?tail drop ;

PRIVATE>

: edit-vocab ( vocab -- )
    public-vocab-name >vocab-link edit ;

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
    public-vocab-name vocab-docs-path 1 edit-location ;

M: word edit-docs
    dup "help-loc" word-prop
    [ nip first2 edit-location ]
    [ vocabulary>> edit-docs ]
    if* ;

GENERIC: edit-tests ( object -- )

M: object edit-tests
    public-vocab-name vocab-tests-path 1 edit-location ;

M: word edit-tests vocabulary>> edit-tests ;

: edit-platforms ( vocab -- )
    dup vocab-platforms-path vocab-append-path 1 edit-location ;

: edit-authors ( vocab -- )
    dup vocab-authors-path vocab-append-path 1 edit-location ;

: edit-tags ( vocab -- )
    dup vocab-tags-path vocab-append-path 1 edit-location ;

: edit-summary ( vocab -- )
    dup vocab-summary-path vocab-append-path 1 edit-location ;
