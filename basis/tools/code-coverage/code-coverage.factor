! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel quotations sequences strings
tools.annotations vocabs words prettyprint io ;
IN: tools.code-coverage

TUPLE: coverage < identity-tuple executed? ;

C: <coverage> coverage

GENERIC: code-coverage-on ( object -- )

GENERIC: code-coverage-off ( object -- )

M: string code-coverage-on
    words [ code-coverage-on ] each ;

M: string code-coverage-off ( vocabulary -- )
    words [ code-coverage-off ] each ;

M: word code-coverage-on ( word -- )
    H{ } clone [ "code-coverage" set-word-prop ] 2keep
    '[
        coverage new [ _ set-at ] 2keep
        '[ _ t >>executed? drop ] [ ] surround
    ] deep-annotate ;

M: word code-coverage-off ( word -- )
    [ reset ] [ f "code-coverage" set-word-prop ] bi ;

GENERIC: untested ( object -- seq )

M: string untested
    words [ dup untested ] { } map>assoc ;

M: word untested ( word -- seq )
    "code-coverage" word-prop >alist
    [ drop executed?>> not ] assoc-filter values ;

GENERIC: show-untested ( object -- )

M: string show-untested
    words [ show-untested ] each ;

M: word show-untested
    dup untested [
        drop
    ] [
        [ name>> ":" append print ]
        [ [ bl bl bl bl . ] each ] bi*
    ] if-empty ;
