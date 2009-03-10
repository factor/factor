! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors sequences parser kernel help help.markup
help.topics words strings classes tools.vocabs namespaces make
io io.streams.string prettyprint definitions arrays vectors
combinators combinators.short-circuit splitting debugger
hashtables sorting effects vocabs vocabs.loader assocs editors
continuations classes.predicate macros math sets eval
vocabs.parser words.symbol values grouping unicode.categories
sequences.deep call ;
IN: help.lint

SYMBOL: vocabs-quot

: check-example ( element -- )
    [
        rest [
            but-last "\n" join
            [ (eval>string) ] call( code -- output )
            "\n" ?tail drop
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
    } swap '[ _ elements empty? not ] any? ;

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

: check-nulls ( element -- )
    \ $values swap elements
    null swap deep-member?
    [ "$values should not contain null" throw ] when ;

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

: check-strings ( str -- )
    [
        "\n\t" intersects?
        [ "Paragraph text should not contain \\n or \\t" throw ] when
    ] [
        "  " swap subseq?
        [ "Paragraph text should not contain double spaces" throw ] when
    ] bi ;

: check-whitespace ( str1 str2 -- )
    [ " " tail? ] [ " " head? ] bi* or
    [ "Missing whitespace between strings" throw ] unless ;

: check-bogus-nl ( element -- )
    { { $nl } { { $nl } } } [ head? ] with any?
    [ "Simple element should not begin with a paragraph break" throw ] when ;

: check-elements ( element -- )
    {
        [ check-bogus-nl ]
        [ [ string? ] filter [ check-strings ] each ]
        [ [ simple-element? ] filter [ check-elements ] each ]
        [ 2 <clumps> [ [ string? ] all? ] filter [ first2 check-whitespace ] each ]
    } cleave ;

: check-descriptions ( element -- )
    { $description $class-description $var-description }
    swap '[
        _ elements [
            rest { { } { "" } } member?
            [ "Empty description" throw ] when
        ] each
    ] each ;

: check-markup ( element -- )
    {
        [ check-elements ]
        [ check-rendering ]
        [ check-examples ]
        [ check-modules ]
        [ check-descriptions ]
    } cleave ;

: check-class-description ( word element -- )
    [ class? not ]
    [ { $class-description } swap elements empty? not ] bi* and
    [ "A word that is not a class has a $class-description" throw ] when ;

: all-word-help ( words -- seq )
    [ word-help ] filter ;

TUPLE: help-error error topic ;

C: <help-error> help-error

M: help-error error.
    [ "In " write topic>> pprint nl ]
    [ error>> error. ]
    bi ;

: check-something ( obj quot -- )
    flush '[ _ call( -- ) ] swap '[ _ <help-error> , ] recover ; inline

: check-word ( word -- )
    [ with-file-vocabs ] vocabs-quot set
    dup word-help [
        dup '[
            _ dup word-help
            [ check-values ]
            [ check-class-description ]
            [ nip [ check-nulls ] [ check-see-also ] [ check-markup ] tri ] 2tri
        ] check-something
    ] [ drop ] if ;

: check-words ( words -- ) [ check-word ] each ;

: check-article-title ( article -- )
    article-title first LETTER?
    [ "Article title must begin with a capital letter" throw ] unless ;

: check-article ( article -- )
    [ with-interactive-vocabs ] vocabs-quot set
    dup '[
        _
        [ check-article-title ]
        [ article-content check-markup ] bi
    ] check-something ;

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
