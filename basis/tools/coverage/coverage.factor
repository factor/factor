! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel quotations sequences strings
tools.annotations vocabs words prettyprint io splitting ;
IN: tools.coverage

TUPLE: coverage < identity-tuple executed? ;

C: <coverage> coverage

: private-vocab-name ( string -- string' )
    ".private" ?tail drop ".private" append ;

GENERIC: coverage-on ( object -- )

GENERIC: coverage-off ( object -- )

: change-coverage ( string quot -- )
    over ".private" tail? [
        [ words ] dip each
    ] [
        [ [ private-vocab-name words ] dip each ]
        [ [ words ] dip each ] 2bi
    ] if ; inline

M: string coverage-on
    [ coverage-on ] change-coverage ;

M: string coverage-off ( vocabulary -- )
    [ coverage-off ] change-coverage ;

M: word coverage-on ( word -- )
    H{ } clone [ "coverage" set-word-prop ] 2keep
    '[
        \ coverage new [ _ set-at ] 2keep
        '[ _ t >>executed? drop ] [ ] surround
    ] deep-annotate ;

M: word coverage-off ( word -- )
    [ reset ] [ f "coverage" set-word-prop ] bi ;

GENERIC: toggle-coverage ( object -- )

M: string toggle-coverage
    words [ toggle-coverage ] each ;

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
