! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences parser kernel help help.markup help.topics
words strings classes tools.browser namespaces io
io.streams.string prettyprint definitions arrays vectors
combinators splitting debugger hashtables sorting effects vocabs
vocabs.loader assocs editors continuations classes.predicate
macros combinators.lib ;
IN: help.lint

: check-example ( element -- )
    1 tail [
        1 head* "\n" join 1vector
        [
            use [ clone ] change
            [ eval>string ] with-datastack
        ] with-scope peek "\n" ?tail drop
    ] keep
    peek assert= ;

: check-examples ( word element -- )
    nip \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements dup empty? [
        first 1 tail [ first ] map prune natural-sort
    ] unless ;

: effect-values ( word -- seq )
    stack-effect dup effect-in swap effect-out
    append [ string? ] subset prune natural-sort ;

: contains-funky-elements? ( element -- ? )
    {
        $shuffle
        $values-x/y
        $slot-reader
        $slot-writer
        $predicate
        $class-description
        $error-description
    } swap [ elements f like ] curry contains? ;

: check-values ( word element -- )
    {
        [ over "declared-effect" word-prop ]
        [ dup contains-funky-elements? not ]
        [ over macro? not ]
        [
            2dup extract-values >array
            >r effect-values >array
            r> assert=
            t
        ]
    } && 3drop ;

: check-see-also ( word element -- )
    nip \ $see-also swap elements [
        1 tail dup prune [ length ] 2apply assert=
    ] each ;

: vocab-exists? ( name -- ? )
    dup vocab swap "all-vocabs" get member? or ;

: check-modules ( word element -- )
    nip \ $vocab-link swap elements [
        second
        vocab-exists? [ "Missing vocabulary" throw ] unless
    ] each ;

: check-rendering ( word element -- )
    [ help ] string-out drop ;

: all-word-help ( words -- seq )
    [ word-help ] subset ;

TUPLE: help-error topic ;

: <help-error> ( topic delegate -- error )
    { set-help-error-topic set-delegate } help-error construct ;

M: help-error error.
    "In " write dup help-error-topic ($link) nl
    delegate error. ;

: check-something ( obj quot -- )
    over . flush [ <help-error> , ] recover ; inline

: check-word ( word -- )
    dup word-help [
        [
            dup word-help [
                2dup check-examples
                2dup check-values
                2dup check-see-also
                2dup check-modules
                2dup drop check-rendering
            ] assert-depth 2drop
        ] check-something
    ] [ drop ] if ;

: check-words ( words -- ) [ check-word ] each ;

: check-article ( article -- )
    [
        [ dup check-rendering ] assert-depth drop
    ] check-something ;

: check-articles ( -- )
    articles get keys [ check-article ] each ;

: with-help-lint ( quot -- )
    [
        all-vocabs-seq [ vocab-name ] map "all-vocabs" set
        call
    ] { } make [ nl error. ] each ; inline

: check-help ( -- )
    [ all-words check-words check-articles ] with-help-lint ;

: check-vocab-help ( vocab -- )
    [
        child-vocabs [ words check-words ] each
    ] with-help-lint ;

: unlinked-words ( words -- seq )
    all-word-help [ article-parent not ] subset ;

: linked-undocumented-words ( -- seq )
    all-words
    [ word-help not ] subset
    [ article-parent ] subset
    [ "predicating" word-prop not ] subset ;

MAIN: check-help
