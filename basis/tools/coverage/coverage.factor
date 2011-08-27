! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel quotations sequences strings
tools.annotations vocabs words prettyprint io splitting ;
IN: tools.coverage

TUPLE: coverage < identity-tuple executed? ;

C: <coverage> coverage

GENERIC: coverage-on ( object -- )

GENERIC: coverage-off ( object -- )

<PRIVATE

: private-vocab-name ( string -- string' )
    ".private" ?tail drop ".private" append ;

: each-word ( string quot -- )
    over ".private" tail? [
        [ words ] dip each
    ] [
        [ [ private-vocab-name words ] dip each ]
        [ [ words ] dip each ] 2bi
    ] if ; inline

: map-word ( string quot -- seq )
    over ".private" tail? [
        [ words ] dip map
    ] [
        [ [ private-vocab-name words ] dip map ]
        [ [ words ] dip map ] 2bi append
    ] if ; inline

PRIVATE>

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
    words [ dup coverage ] { } map>assoc ;

M: word coverage ( word -- seq )
    "coverage" word-prop >alist
    [ drop executed?>> not ] assoc-filter values ;

GENERIC: coverage. ( object -- )

M: string coverage.
    words [ coverage. ] each ;

M: word coverage.
    dup coverage [
        drop
    ] [
        [ name>> ":" append print ]
        [ [ bl bl bl bl . ] each ] bi*
    ] if-empty ;

GENERIC: count-callables ( object -- n )

M: string count-callables
    [ count-callables ] map-word sum ;

M: word count-callables
    def>> [ callable? ] deep-filter length ;

GENERIC: %coverage ( object -- x )

: calculate-%coverage ( object quot -- x )
    [ count-callables ] bi [ swap - ] keep /f ; inline

M: string %coverage
    [ coverage values concat length ] calculate-%coverage ;

M: word %coverage
    [ coverage length ] calculate-%coverage ;
