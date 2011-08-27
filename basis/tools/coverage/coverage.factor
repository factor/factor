! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry io kernel math prettyprint
quotations sequences sequences.deep splitting strings
tools.annotations vocabs words arrays words.symbol
combinators.short-circuit ;
IN: tools.coverage

TUPLE: coverage < identity-tuple executed? ;

C: <coverage> coverage

GENERIC: coverage-on ( object -- )

GENERIC: coverage-off ( object -- )

<PRIVATE

: private-vocab-name ( string -- string' )
    ".private" ?tail drop ".private" append ;

: coverage-words ( string -- words )
    words [ { [ primitive? not ] [ symbol? not ] } 1&& ] filter ;

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

M: string coverage-on
    [ coverage-on ] each-word ;

M: string coverage-off ( vocabulary -- )
    [ coverage-off ] each-word ;

M: word coverage-on ( word -- )
    H{ } clone [ "coverage" set-word-prop ] 2keep
    '[
        \ coverage new [ _ set-at ] 2keep
        '[ _ t >>executed? drop ] prepend
    ] deep-annotate ;

M: word coverage-off ( word -- )
    [ reset ] [ f "coverage" set-word-prop ] bi ;

GENERIC: toggle-coverage ( object -- )

M: string toggle-coverage
    [ toggle-coverage ] each-word ;

M: word toggle-coverage
    dup "coverage" word-prop [
        coverage-off
    ] [
        coverage-on
    ] if ;

GENERIC: coverage ( object -- seq )

M: string coverage
    [ dup coverage 2array ] map-words ;

M: word coverage ( word -- seq )
    "coverage" word-prop >alist
    [ drop executed?>> not ] assoc-filter values ;

GENERIC: coverage. ( object -- )

M: string coverage.
    [ coverage. ] each-word ;

M: word coverage.
    dup coverage [
        drop
    ] [
        [ name>> ":" append print ]
        [ [ "    " write . ] each ] bi*
    ] if-empty ;

<PRIVATE

GENERIC: count-callables ( object -- n )

M: string count-callables
    [ count-callables ] map-words sum ;

M: word count-callables
    "coverage" word-prop assoc-size ;

PRIVATE>

: %coverage ( string -- x )
    [ coverage values concat length ]
    [ count-callables ] bi [ swap - ] keep /f ; inline
