IN: temporary
USING: kernel math namespaces tools.test vectors sequences
sequences.private hashtables io prettyprint assocs
continuations ;

[ t ] [ H{ } dup subassoc? ] unit-test
[ f ] [ H{ { 1 3 } } H{ } subassoc? ] unit-test
[ t ] [ H{ } H{ { 1 3 } } subassoc? ] unit-test
[ t ] [ H{ { 1 3 } } H{ { 1 3 } } subassoc? ] unit-test
[ f ] [ H{ { 1 3 } } H{ { 1 "hey" } } subassoc? ] unit-test
[ f ] [ H{ { 1 f } } H{ } subassoc? ] unit-test
[ t ] [ H{ { 1 f } } H{ { 1 f } } subassoc? ] unit-test

! Test some combinators
[
    { 4 14 32 }
] [
    [
        H{
            { 1 2 }
            { 3 4 }
            { 5 6 }
        } [ * 2 + , ] assoc-each
    ] { } make
] unit-test

[ t ] [ H{ } [ 2drop f ] assoc-all? ] unit-test
[ t ] [ H{ { 1 1 } } [ = ] assoc-all? ] unit-test
[ f ] [ H{ { 1 2 } } [ = ] assoc-all? ] unit-test
[ t ] [ H{ { 1 1 } { 2 2 } } [ = ] assoc-all? ] unit-test
[ f ] [ H{ { 1 2 } { 2 2 } } [ = ] assoc-all? ] unit-test

[ H{ } ] [ H{ { t f } { f t } } [ 2drop f ] assoc-subset ] unit-test
[ H{ { 3 4 } { 4 5 } { 6 7 } } ] [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop 3 >= ] assoc-subset
] unit-test

[ 21 ] [
    0 H{
        { 1 2 }
        { 3 4 }
        { 5 6 }
    } [
        + +
    ] assoc-each
] unit-test

H{ } clone "cache-test" set

[ 4 ] [ 1 "cache-test" get [ 3 + ] cache ] unit-test
[ 5 ] [ 2 "cache-test" get [ 3 + ] cache ] unit-test
[ 4 ] [ 1 "cache-test" get [ 3 + ] cache ] unit-test
[ 5 ] [ 2 "cache-test" get [ 3 + ] cache ] unit-test

[
    H{ { "factor" "rocks" } { 3 4 } }
] [
    H{ { "factor" "rocks" } { "dup" "sq" } { 3 4 } }
    H{ { "factor" "rocks" } { 1 2 } { 2 3 } { 3 4 } }
    intersect
] unit-test

[
    H{ { 1 2 } { 2 3 } { 6 5 } }
] [
    H{ { 2 4 } { 6 5 } } H{ { 1 2 } { 2 3 } }
    union
] unit-test

[ H{ { 1 2 } { 2 3 } } t ] [
    f H{ { 1 2 } { 2 3 } } [ union ] 2keep swap union dupd =
] unit-test

[
    H{ { 1 f } }
] [
    H{ { 1 f } } H{ { 1 f } } intersect
] unit-test

[ { 1 3 } ] [ H{ { 2 2 } } { 1 2 3 } remove-all ] unit-test

[ H{ { "hi" 2 } { 3 4 } } ]
[ "hi" 1 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test

[ H{ { 1 2 } { 3 4 } } ]
[ "hi" 5 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test
