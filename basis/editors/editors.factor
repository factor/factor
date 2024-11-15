! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar classes.parser
classes.singleton combinators.smart continuations debugger
definitions io io.launcher io.pathnames kernel lexer namespaces
parser.notes prettyprint sequences sets source-files.errors
splitting strings threads tools.crossref tools.scaffold vocabs
vocabs.files vocabs.hierarchy vocabs.loader vocabs.metadata
vocabs.parser words ;
IN: editors

SYMBOL: editor-class

: available-editors ( -- seq )
    "editors" disk-child-vocab-names
    { "editors.ui" "editors.private" } diff
    [ vocab-platforms supported-platform? ] filter
    [ "editors." ?head drop ] map ;

: editor-restarts ( -- alist )
    available-editors
    [ [ "Load " prepend ] keep ] map>alist ;

: set-editor ( string -- )
    "editors." ?head drop
    [ "editors." prepend t parser-quiet? [ use-vocab ] with-variable ]
    [ search ] bi
    editor-class set-global ;

SYNTAX: EDITOR: scan-token set-editor ;

HOOK: editor-command editor-class ( file line -- command )

: write-pprint ( obj -- ) dup string? [ write ] [ pprint ] if ;
: print-pprint ( obj -- ) dup string? [ print ] [ pprint nl ] if ;

: pprint-line ( seq -- )
    [
        dup string?
        [ print ]
        [ unclip-last [ [ write-pprint ] each ] [ print-pprint ] bi* ] if
    ] unless-empty ; inline

M: f editor-command
    "Select an editor" editor-restarts throw-restarts
    [ set-editor ]
    [
        "Note:" print
        '[
            "To make this editor permanent, in your "
            ".factor-boot-rc" home-path
            " or "
            ".factor-rc" home-path
            " add:\n"
            "USE: editors EDITOR: " _ append
        ] output>array pprint-line
    ] bi
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
    "Cannot find source for '" write
    definition>> pprint-short
    "'" print ;

: edit-file ( path -- )
    0 edit-location ;

DEFER: edit

: edit-vocab ( vocab -- )
    >vocab-link edit ;

GENERIC: edit ( object -- )

M: object edit
    [ where ] [ first2 edit-location ] [ cannot-find-source ] ?if ;

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
    vocab-docs-path 1 edit-location ;

M: word edit-docs
    dup "help-loc" word-prop
    [ nip first2 edit-location ]
    [ vocabulary>> edit-docs ]
    if* ;

GENERIC: edit-tests ( object -- )

M: object edit-tests
    vocab-tests-path 1 edit-location ;

M: word edit-tests vocabulary>> edit-tests ;

: edit-platforms ( vocab -- )
    vocab-platforms-path 1 edit-location ;

: edit-authors ( vocab -- )
    vocab-authors-path 1 edit-location ;

: edit-tags ( vocab -- )
    vocab-tags-path 1 edit-location ;

: edit-summary ( vocab -- )
    vocab-summary-path 1 edit-location ;
