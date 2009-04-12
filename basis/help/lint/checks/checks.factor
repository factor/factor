! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
combinators.short-circuit definitions effects eval fry grouping
help help.markup help.topics io.streams.string kernel macros
namespaces sequences sequences.deep sets sorting splitting
strings unicode.categories values vocabs vocabs.loader words
words.symbol summary debugger io ;
IN: help.lint.checks

ERROR: simple-lint-error message ;

M: simple-lint-error summary message>> ;

M: simple-lint-error error. summary print ;

SYMBOL: vocabs-quot
SYMBOL: all-vocabs
SYMBOL: vocab-articles

: check-example ( element -- )
    '[
        _ rest [
            but-last "\n" join
            [ (eval>string) ] call( code -- output )
            "\n" ?tail drop
        ] keep
        peek assert=
    ] vocabs-quot get call( quot -- ) ;

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
    } 2|| [ "$values don't match stack effect" simple-lint-error ] unless ;

: check-nulls ( element -- )
    \ $values swap elements
    null swap deep-member?
    [ "$values should not contain null" simple-lint-error ] when ;

: check-see-also ( element -- )
    \ $see-also swap elements [
        rest dup prune [ length ] bi@ assert=
    ] each ;

: vocab-exists? ( name -- ? )
    [ vocab ] [ all-vocabs get member? ] bi or ;

: check-modules ( element -- )
    \ $vocab-link swap elements [
        second
        vocab-exists? [
            "$vocab-link to non-existent vocabulary"
            simple-lint-error
        ] unless
    ] each ;

: check-rendering ( element -- )
    [ print-content ] with-string-writer drop ;

: check-strings ( str -- )
    [
        "\n\t" intersects? [
            "Paragraph text should not contain \\n or \\t"
            simple-lint-error
        ] when
    ] [
        "  " swap subseq? [
            "Paragraph text should not contain double spaces"
            simple-lint-error
        ] when
    ] bi ;

: check-whitespace ( str1 str2 -- )
    [ " " tail? ] [ " " head? ] bi* or
    [ "Missing whitespace between strings" simple-lint-error ] unless ;

: check-bogus-nl ( element -- )
    { { $nl } { { $nl } } } [ head? ] with any? [
        "Simple element should not begin with a paragraph break"
        simple-lint-error
    ] when ;

: check-class-description ( word element -- )
    [ class? not ]
    [ { $class-description } swap elements empty? not ] bi* and
    [ "A word that is not a class has a $class-description" simple-lint-error ] when ;

: check-article-title ( article -- )
    article-title first LETTER?
    [ "Article title must begin with a capital letter" simple-lint-error ] unless ;

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

: all-word-help ( words -- seq )
    [ word-help ] filter ;
