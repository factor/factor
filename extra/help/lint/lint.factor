! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences parser kernel help help.markup help.topics
words strings classes tools.browser namespaces io
io.streams.string prettyprint definitions arrays vectors
combinators splitting debugger hashtables sorting effects vocabs
vocabs.loader assocs editors continuations classes.predicate ;
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

: check-values ( word element -- )
    {
        $shuffle
        $values-x/y
        $slot-reader
        $slot-writer
        $predicate
        $class-description
        $error-description
    }
    over [ elements empty? ] curry all?
    pick "declared-effect" word-prop and
    [ extract-values >array >r effect-values >array r> assert= ]
    [ 2drop ] if ;

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

: all-word-help ( -- seq )
    all-words [ word-help ] subset ;

TUPLE: help-error topic ;

: <help-error> ( topic delegate -- error )
    { set-help-error-topic set-delegate } help-error construct ;

: fix-help ( error -- )
    dup delegate error.
    help-error-topic >link edit
    "Press ENTER when done." print flush readln drop
    refresh-all ;

: check-word ( word -- )
    dup . flush
    [
        dup word-help [
            2dup check-examples
            2dup check-values
            2dup check-see-also
            2dup check-modules
            2dup drop check-rendering
        ] assert-depth 2drop
    ] [
        dupd <help-error> fix-help check-word
    ] recover ;

: check-words ( -- )
    [
        all-vocabs-seq [ vocab-name ] map
        "all-vocabs" set
        all-word-help [ check-word ] each
    ] with-scope ;

: check-article ( article -- )
    dup . flush
    [
        [ dup check-rendering ] assert-depth drop
    ] [
        dupd <help-error> fix-help check-article
    ] recover ;

: check-articles ( -- )
    articles get keys [ check-article ] each ;

: check-help ( -- ) check-words check-articles ;

: unlinked-words ( -- seq )
    all-word-help [ article-parent not ] subset ;

: linked-undocumented-words ( -- seq )
    all-words
    [ word-help not ] subset
    [ article-parent ] subset
    [ "predicating" word-prop not ] subset ;

MAIN: check-help
