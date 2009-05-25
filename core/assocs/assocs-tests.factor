IN: assocs.tests
USING: kernel math namespaces make tools.test vectors sequences
sequences.private hashtables io prettyprint assocs
continuations specialized-arrays.double ;

[ t ] [ H{ } dup assoc-subset? ] unit-test
[ f ] [ H{ { 1 3 } } H{ } assoc-subset? ] unit-test
[ t ] [ H{ } H{ { 1 3 } } assoc-subset? ] unit-test
[ t ] [ H{ { 1 3 } } H{ { 1 3 } } assoc-subset? ] unit-test
[ f ] [ H{ { 1 3 } } H{ { 1 "hey" } } assoc-subset? ] unit-test
[ f ] [ H{ { 1 f } } H{ } assoc-subset? ] unit-test
[ t ] [ H{ { 1 f } } H{ { 1 f } } assoc-subset? ] unit-test

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

[ H{ } ] [ H{ { t f } { f t } } [ 2drop f ] assoc-filter ] unit-test
[ H{ { 3 4 } { 4 5 } { 6 7 } } ] [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop 3 >= ] assoc-filter
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
    assoc-intersect
] unit-test

[
    H{ { 1 2 } { 2 3 } { 6 5 } }
] [
    H{ { 2 4 } { 6 5 } } H{ { 1 2 } { 2 3 } }
    assoc-union
] unit-test

[ H{ { 1 2 } { 2 3 } } t ] [
    f H{ { 1 2 } { 2 3 } } [ assoc-union ] 2keep swap assoc-union dupd =
] unit-test

[
    H{ { 1 f } }
] [
    H{ { 1 f } } H{ { 1 f } } assoc-intersect
] unit-test

[ { 1 3 } ] [ H{ { 2 2 } } { 1 2 3 } remove-all ] unit-test

[ H{ { "hi" 2 } { 3 4 } } ]
[ "hi" 1 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test

[ H{ { 1 2 } { 3 4 } } ]
[ "hi" 5 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test

[
    H{ { 1.0 1.0 } { 2.0 2.0 } }
] [
    double-array{ 1.0 2.0 } [ dup ] H{ } map>assoc
] unit-test

[ { 3 } ] [
    [
        3
        H{ } clone
        2 [
            2dup [ , f ] cache drop
        ] times
        2drop
    ] { } make
] unit-test

[
    H{
        { "bangers" "mash" }
        { "fries" "onion rings" }
    }
] [
    { "bangers" "fries" } H{
        { "fish" "chips" }
        { "bangers" "mash" }
        { "fries" "onion rings" }
        { "nachos" "cheese" }
    } extract-keys
] unit-test

[ H{ { "b" [ 2 ] } { "d" [ 4 ] } } H{ { "a" [ 1 ] } { "c" [ 3 ] } } ] [
    H{
        { "a" [ 1 ] }
        { "b" [ 2 ] }
        { "c" [ 3 ] }
        { "d" [ 4 ] }
    } [ nip first even? ] assoc-partition
] unit-test

[ 1 f ] [ 1 H{ } ?at ] unit-test
[ 2 t ] [ 1 H{ { 1 2 } } ?at ] unit-test
