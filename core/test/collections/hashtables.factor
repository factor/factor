IN: temporary
USE: kernel
USE: math
USE: namespaces
USE: test
USE: vectors
USE: sequences
USE: sequences-internals
USE: hashtables
USE: io
USE: prettyprint
USE: errors

[ "hi" V{ 1 2 3 } hash ] unit-test-fails

[ H{ } ] [ { } [ dup ] map>hash ] unit-test

[ ] [ 1000 [ dup sq ] map>hash "testhash" set ] unit-test

[ V{ } ]
[ 1000 [ dup sq swap "testhash" get hash = not ] subset ]
unit-test

[ t ]
[ "testhash" get hashtable? ]
unit-test

[ f ]
[ { 1 { 2 3 } } hashtable? ]
unit-test

! Test some hashcodes.

[ t ] [ [ 1 2 3 ] hashcode [ 1 2 3 ] hashcode = ] unit-test
[ t ] [ [ 1 [ 2 3 ] 4 ] hashcode [ 1 [ 2 3 ] 4 ] hashcode = ] unit-test

[ t ] [ 12 hashcode 12 hashcode = ] unit-test
[ t ] [ 12 >bignum hashcode 12 hashcode = ] unit-test
[ t ] [ 12.0 hashcode 12 >bignum hashcode = ] unit-test

! Test various odd keys to see if they work.

16 <hashtable> "testhash" set

t C{ 2 3 } "testhash" get set-hash
f 100000000000000000000000000 "testhash" get set-hash
{ } { [ { } ] } "testhash" get set-hash

[ t ] [ C{ 2 3 } "testhash" get hash ] unit-test
[ f ] [ 100000000000000000000000000 "testhash" get hash* drop ] unit-test
[ { } ] [ { [ { } ] } clone "testhash" get hash* drop ] unit-test

! Regression
3 <hashtable> "broken-remove" set
1 W{ \ + } dup "x" set "broken-remove" get set-hash
2 W{ \ = } dup "y" set "broken-remove" get set-hash
"x" get "broken-remove" get remove-hash
2 "y" get "broken-remove" get set-hash
[ 1 ] [ "broken-remove" get hash-keys length ] unit-test

{
    { "salmon" "fish" }
    { "crocodile" "reptile" }
    { "cow" "mammal" }
    { "visual basic" "language" }
} alist>hash "testhash" set

[ f f ] [
    "visual basic" "testhash" get remove-hash
    "visual basic" "testhash" get hash*
] unit-test

[ t ] [ H{ } dup subhash? ] unit-test
[ f ] [ H{ { 1 3 } } H{ } subhash? ] unit-test
[ t ] [ H{ } H{ { 1 3 } } subhash? ] unit-test
[ t ] [ H{ { 1 3 } } H{ { 1 3 } } subhash? ] unit-test
[ f ] [ H{ { 1 3 } } H{ { 1 "hey" } } subhash? ] unit-test
[ f ] [ H{ { 1 f } } H{ } subhash? ] unit-test
[ t ] [ H{ { 1 f } } H{ { 1 f } } subhash? ] unit-test

[ t ] [ H{ } dup = ] unit-test
[ f ] [ "xyz" H{ } = ] unit-test
[ t ] [ H{ } H{ } = ] unit-test
[ f ] [ H{ { 1 3 } } H{ } = ] unit-test
[ f ] [ H{ } H{ { 1 3 } } = ] unit-test
[ t ] [ H{ { 1 3 } } H{ { 1 3 } } = ] unit-test
[ f ] [ H{ { 1 3 } } H{ { 1 "hey" } } = ] unit-test

! Test some combinators
[
    { 4 14 32 }
] [
    [
        2 H{
            { 1 2 }
            { 3 4 }
            { 5 6 }
        } [ * + , ] hash-each-with
    ] { } make
] unit-test

[ t ] [ H{ } [ 2drop f ] hash-all? ] unit-test
[ t ] [ H{ { 1 1 } } [ = ] hash-all? ] unit-test
[ f ] [ H{ { 1 2 } } [ = ] hash-all? ] unit-test
[ t ] [ H{ { 1 1 } { 2 2 } } [ = ] hash-all? ] unit-test
[ f ] [ H{ { 1 2 } { 2 2 } } [ = ] hash-all? ] unit-test

[ H{ } ] [ H{ { t f } { f t } } [ 2drop f ] hash-subset ] unit-test
[ H{ { 3 4 } { 4 5 } { 6 7 } } ] [
    3 H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop <= ] hash-subset-with
] unit-test

! Testing the hash element counting

H{ } clone "counting" set
"value" "key" "counting" get set-hash
[ 1 ] [ "counting" get hash-size ] unit-test
"value" "key" "counting" get set-hash
[ 1 ] [ "counting" get hash-size ] unit-test
"key" "counting" get remove-hash
[ 0 ] [ "counting" get hash-size ] unit-test
"key" "counting" get remove-hash
[ 0 ] [ "counting" get hash-size ] unit-test

! Test rehashing

2 <hashtable> "rehash" set

1 1 "rehash" get set-hash
2 2 "rehash" get set-hash
3 3 "rehash" get set-hash
4 4 "rehash" get set-hash
5 5 "rehash" get set-hash
6 6 "rehash" get set-hash

[ 6 ] [ "rehash" get hash-size ] unit-test

[ 6 ] [ "rehash" get clone hash-size ] unit-test

"rehash" get clear-hash

[ 0 ] [ "rehash" get hash-size ] unit-test

[
    3
] [
    2 H{
        { 1 2 }
        { 2 3 }
    } clone hash
] unit-test

! There was an assoc in place of assoc* somewhere
3 <hashtable> "f-hash-test" set

10 [ f f "f-hash-test" get set-hash ] times

[ 1 ] [ "f-hash-test" get hash-size ] unit-test

[ 21 ] [
    0 H{
        { 1 2 }
        { 3 4 }
        { 5 6 }
    } [
        + +
    ] hash-each
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
    hash-intersect
] unit-test

[
    H{ { 1 2 } { 2 3 } }
] [
    H{ { "factor" "rocks" } { "dup" "sq" } { 3 4 } }
    H{ { "factor" "rocks" } { 1 2 } { 2 3 } { 3 4 } }
    hash-diff
] unit-test

[
    H{ { 1 2 } { 2 3 } { 6 5 } }
] [
    H{ { 2 4 } { 6 5 } } H{ { 1 2 } { 2 3 } }
    hash-union
] unit-test

[ { 1 3 } ] [ H{ { 2 2 } } { 1 2 3 } remove-all ] unit-test

! Resource leak...
H{ } "x" set
100 [ drop "x" get clear-hash ] each

! Crash discovered by erg
[ t ] [ 3/4 <hashtable> dup clone = ] unit-test

! Another crash discovered by erg
[ ] [
    H{ } clone
    [ 1 swap set-hash ] catch drop
    [ 2 swap set-hash ] catch drop
    [ 3 swap set-hash ] catch drop
    drop
] unit-test
