! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators.short-circuit
continuations io kernel math namespaces prettyprint quotations
sequences sequences.deep splitting strings tools.annotations
tools.test.private vocabs words words.symbol ;
IN: tools.coverage

TUPLE: coverage-state < identity-tuple executed? ;

C: <coverage-state> coverage-state

SYMBOL: covered

: flag-covered ( coverage -- )
    covered get-global [ t >>executed? ] when drop ;

: coverage-on ( -- ) t covered set-global ;

: coverage-off ( -- ) f covered set-global ;

GENERIC: add-coverage ( object -- )

GENERIC: remove-coverage ( object -- )

GENERIC: reset-coverage ( object -- )

<PRIVATE

: private-vocab-name ( string -- string' )
    ".private" ?tail drop ".private" append ;

: coverage-words ( string -- words )
    vocab-words [
        {
            [ primitive? not ]
            [ symbol? not ]
            [ predicate? not ]
        } 1&&
    ] filter ;

PRIVATE>

: each-word ( string quot -- )
    over ".private" tail? [
        [ coverage-words ] dip each
    ] [
        [ [ private-vocab-name coverage-words ] dip each ]
        [ [ coverage-words ] dip each ] 2bi
    ] if ; inline

: map-words ( string quot -- sequence )
    over ".private" tail? [
        [ coverage-words ] dip map
    ] [
        [ [ private-vocab-name coverage-words ] dip map ]
        [ [ coverage-words ] dip map ] 2bi append
    ] if ; inline

M: string add-coverage
    [ add-coverage ] each-word ;

M: string remove-coverage
    [ remove-coverage ] each-word ;

M: word add-coverage
    H{ } clone [ "coverage" set-word-prop ] 2keep
    '[
        \ coverage-state new [ _ set-at ] 2keep
        '[ _ flag-covered ] prepend
    ] deep-annotate ;

M: word remove-coverage
    [ reset ] [ "coverage" remove-word-prop ] bi ;

M: string reset-coverage
    [ reset-coverage ] each-word ;

M: word reset-coverage
    [ dup coverage-state? [ f >>executed? ] when drop ] each-word ;

GENERIC: coverage ( object -- seq )

M: string coverage
    [ dup coverage 2array ] map-words ;

M: word coverage
    "coverage" word-prop
    [ drop executed?>> ] assoc-reject values ;

GENERIC: coverage. ( object -- )

M: string coverage.
    [ coverage. ] each-word ;

: pair-coverage. ( word seq -- )
    [ drop ] [
        [ name>> ":" append print ]
        [ [ "    " write . ] each ] bi*
    ] if-empty ;

M: word coverage.
    dup coverage pair-coverage. ;

M: sequence coverage.
    [ first2 pair-coverage. ] each ;

<PRIVATE

GENERIC: count-callables ( object -- n )

M: string count-callables
    [ count-callables ] map-words sum ;

M: word count-callables
    def>> 0 [ callable? [ 1 + ] when ] deep-reduce ;

PRIVATE>

: test-coverage ( vocab -- coverage )
    [
        add-coverage
    ] [
        dup '[
            [
                _
                [ coverage-on test-vocab coverage-off ]
                [ coverage ] bi
            ] [ _ remove-coverage ] finally
        ] call
    ] bi ;

: coverage-vocab? ( vocab -- ? )
    { [ ".private" tail? ] [ ".tests" tail? ] } 1|| not ;

: test-coverage-recursively ( prefix -- assoc )
    loaded-child-vocab-names [ coverage-vocab? ] filter
    [ dup test-coverage ] { } map>assoc ;

: %coverage ( string -- x )
    [ test-coverage values concat length ]
    [ count-callables ] bi [ swap - ] keep /f ; inline
