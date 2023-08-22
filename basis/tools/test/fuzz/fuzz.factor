! (c)2011 Andrew Pennebaker, Joe Groff
USING: accessors combinators.smart fry io kernel make math
math.parser namespaces prettyprint random sequences strings
summary tools.test tools.test.private ;
IN: tools.test.fuzz

! Fuzz testing parameters
SYMBOL: fuzz-test-trials
fuzz-test-trials [ 100 ] initialize

: fuzz-test-failures* ( trials generator: ( -- ..a ) predicate: ( ..a -- ? ) -- failures )
    '[
        _ { } output>sequence [ _ input<sequence ] [ f swap ? ] bi
    ] replicate sift ; inline

: fuzz-test-failures ( generator: ( -- ..a ) predicate: ( ..a -- ? ) -- failures )
    [ fuzz-test-trials get ] 2dip fuzz-test-failures* ; inline

<PRIVATE

TUPLE: fuzz-test-failure failures predicate trials ;

C: <fuzz-test-failure> fuzz-test-failure

M: fuzz-test-failure summary
    [
        "Fuzz test predicate failed for " %
        dup failures>> length #
        " out of " %
        trials>> #
        " trials" %
    ] "" make ;

: (fuzz-test) ( generator predicate -- error/f failed? tested? )
    [ fuzz-test-failures [ f f ] ]
    [ '[ _ fuzz-test-trials get <fuzz-test-failure> t ] ] bi
    if-empty t ; inline

PRIVATE>

DEFINE-TEST-WORD: fuzz-test
