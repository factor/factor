! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors sequences parser kernel help help.markup
help.topics words strings classes tools.vocabs namespaces make
io io.streams.string prettyprint definitions arrays vectors
combinators combinators.short-circuit splitting debugger
hashtables sorting effects vocabs vocabs.loader assocs editors
continuations classes.predicate macros math sets eval
vocabs.parser words.symbol values ;
IN: help.lint

SYMBOL: vocabs-quot

: check-example ( element -- )
    [
        rest [
            but-last "\n" join 1vector
            [ (eval>string) ] with-datastack
            peek "\n" ?tail drop
        ] keep
        peek assert=
    ] vocabs-quot get call ;

: check-examples ( element -- )
    \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements dup empty? [
        first rest [ first ] map prune natural-sort
    ] unless ;

: effect-values ( word -- seq )
    stack-effect
    [ in>> ] [ out>> ] bi append
    [ dup pair? [ first ] when effect>string ] map
    prune natural-sort ;

: contains-funky-elements? ( element -- ? )
    {
        $shuffle
        $values-x/y
        $predicate
        $class-description
        $error-description
    } swap '[ _ elements empty? not ] contains? ;

: don't-check-word? ( word -- ? )
    {
        [ macro? ]
        [ symbol? ]
        [ value-word? ]
        [ parsing-word? ]
        [ "declared-effect" word-prop not ]
    } 1|| ;

: check-values ( word element -- )
    {
        [
            [ don't-check-word? ]
            [ contains-funky-elements? ]
            bi* or
        ] [
            [ effect-values ]
            [ extract-values ]
            bi* sequence=
        ]
    } 2|| [ "$values don't match stack effect" throw ] unless ;

: check-see-also ( element -- )
    \ $see-also swap elements [
        rest dup prune [ length ] bi@ assert=
    ] each ;

: vocab-exists? ( name -- ? )
    [ vocab ] [ "all-vocabs" get member? ] bi or ;

: check-modules ( element -- )
    \ $vocab-link swap elements [
        second
        vocab-exists? [ "$vocab-link to non-existent vocabulary" throw ] unless
    ] each ;

: check-rendering ( element -- )
    [ print-content ] with-string-writer drop ;

: check-markup ( element -- )
    [ check-rendering ]
    [ check-examples ]
    [ check-modules ]
    tri ;

: all-word-help ( words -- seq )
    [ word-help ] filter ;

TUPLE: help-error error topic ;

C: <help-error> help-error

M: help-error error.
    [ "In " write topic>> pprint nl ]
    [ error>> error. ]
    bi ;

: check-something ( obj quot -- )
    flush '[ _ assert-depth ] swap '[ _ <help-error> , ] recover ; inline

: check-word ( word -- )
    [ with-file-vocabs ] vocabs-quot set
    dup word-help [
        dup '[
            _ dup word-help
            [ check-values ]
            [ nip [ check-see-also ] [ check-markup ] bi ] 2bi
        ] check-something
    ] [ drop ] if ;

: check-words ( words -- ) [ check-word ] each ;

: check-article ( article -- )
    [ with-interactive-vocabs ] vocabs-quot set
    dup '[ _ article-content check-markup ] check-something ;

: files>vocabs ( -- assoc )
    vocabs
    [ [ [ vocab-docs-path ] keep ] H{ } map>assoc ]
    [ [ [ vocab-source-path ] keep ] H{ } map>assoc ]
    bi assoc-union ;

: group-articles ( -- assoc )
    articles get keys
    files>vocabs
    H{ } clone [
        '[
            dup >link where dup
            [ first _ at _ push-at ] [ 2drop ] if
        ] each
    ] keep ;

: check-about ( vocab -- )
    dup '[ _ vocab-help [ article drop ] when* ] check-something ;

: check-vocab ( vocab -- seq )
    "Checking " write dup write "..." print
    [
        [ check-about ]
        [ words [ check-word ] each ]
        [ "vocab-articles" get at [ check-article ] each ]
        tri
    ] { } make ;

: run-help-lint ( prefix -- alist )
    [
        all-vocabs-seq [ vocab-name ] map "all-vocabs" set
        group-articles "vocab-articles" set
        child-vocabs
        [ dup check-vocab ] { } map>assoc
        [ nip empty? not ] assoc-filter
    ] with-scope ;

: typos. ( assoc -- )
    [
        "==== ALL CHECKS PASSED" print
    ] [
        [
            swap vocab-heading.
            [ print-error nl ] each
        ] assoc-each
    ] if-empty ;

: help-lint ( prefix -- ) run-help-lint typos. ;

: help-lint-all ( -- ) "" help-lint ;

: unlinked-words ( words -- seq )
    all-word-help [ article-parent not ] filter ;

: linked-undocumented-words ( -- seq )
    all-words
    [ word-help not ] filter
    [ article-parent ] filter
    [ "predicating" word-prop not ] filter ;

MAIN: help-lint
