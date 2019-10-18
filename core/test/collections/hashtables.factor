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
USE: assocs

[ f ] [ "hi" V{ 1 2 3 } at ] unit-test

[ H{ } ] [ { } [ dup ] H{ } map>assoc ] unit-test

[ ] [ 1000 [ dup sq ] H{ } map>assoc "testhash" set ] unit-test

[ V{ } ]
[ 1000 [ dup sq swap "testhash" get at = not ] subset ]
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

t C{ 2 3 } "testhash" get set-at
f 100000000000000000000000000 "testhash" get set-at
{ } { [ { } ] } "testhash" get set-at

[ t ] [ C{ 2 3 } "testhash" get at ] unit-test
[ f ] [ 100000000000000000000000000 "testhash" get at* drop ] unit-test
[ { } ] [ { [ { } ] } clone "testhash" get at* drop ] unit-test

! Regression
3 <hashtable> "broken-remove" set
1 W{ \ + } dup "x" set "broken-remove" get set-at
2 W{ \ = } dup "y" set "broken-remove" get set-at
"x" get "broken-remove" get delete-at
2 "y" get "broken-remove" get set-at
[ 1 ] [ "broken-remove" get keys length ] unit-test

{
    { "salmon" "fish" }
    { "crocodile" "reptile" }
    { "cow" "mammal" }
    { "visual basic" "language" }
} >hashtable "testhash" set

[ f f ] [
    "visual basic" "testhash" get delete-at
    "visual basic" "testhash" get at*
] unit-test

[ t ] [ H{ } dup subassoc? ] unit-test
[ f ] [ H{ { 1 3 } } H{ } subassoc? ] unit-test
[ t ] [ H{ } H{ { 1 3 } } subassoc? ] unit-test
[ t ] [ H{ { 1 3 } } H{ { 1 3 } } subassoc? ] unit-test
[ f ] [ H{ { 1 3 } } H{ { 1 "hey" } } subassoc? ] unit-test
[ f ] [ H{ { 1 f } } H{ } subassoc? ] unit-test
[ t ] [ H{ { 1 f } } H{ { 1 f } } subassoc? ] unit-test

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
        } [ * + , ] assoc-each-with
    ] { } make
] unit-test

[ t ] [ H{ } [ 2drop f ] assoc-all? ] unit-test
[ t ] [ H{ { 1 1 } } [ = ] assoc-all? ] unit-test
[ f ] [ H{ { 1 2 } } [ = ] assoc-all? ] unit-test
[ t ] [ H{ { 1 1 } { 2 2 } } [ = ] assoc-all? ] unit-test
[ f ] [ H{ { 1 2 } { 2 2 } } [ = ] assoc-all? ] unit-test

[ H{ } ] [ H{ { t f } { f t } } [ 2drop f ] assoc-subset ] unit-test
[ H{ { 3 4 } { 4 5 } { 6 7 } } ] [
    3 H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop <= ] assoc-subset-with
] unit-test

! Testing the hash element counting

H{ } clone "counting" set
"value" "key" "counting" get set-at
[ 1 ] [ "counting" get assoc-size ] unit-test
"value" "key" "counting" get set-at
[ 1 ] [ "counting" get assoc-size ] unit-test
"key" "counting" get delete-at
[ 0 ] [ "counting" get assoc-size ] unit-test
"key" "counting" get delete-at
[ 0 ] [ "counting" get assoc-size ] unit-test

! Test rehashing

2 <hashtable> "rehash" set

1 1 "rehash" get set-at
2 2 "rehash" get set-at
3 3 "rehash" get set-at
4 4 "rehash" get set-at
5 5 "rehash" get set-at
6 6 "rehash" get set-at

[ 6 ] [ "rehash" get assoc-size ] unit-test

[ 6 ] [ "rehash" get clone assoc-size ] unit-test

"rehash" get clear-assoc

[ 0 ] [ "rehash" get assoc-size ] unit-test

[
    3
] [
    2 H{
        { 1 2 }
        { 2 3 }
    } clone at
] unit-test

! There was an assoc in place of assoc* somewhere
3 <hashtable> "f-hash-test" set

10 [ f f "f-hash-test" get set-at ] times

[ 1 ] [ "f-hash-test" get assoc-size ] unit-test

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

[ { 1 3 } ] [ H{ { 2 2 } } { 1 2 3 } remove-all ] unit-test

! Resource leak...
H{ } "x" set
100 [ drop "x" get clear-assoc ] each

! Crash discovered by erg
[ t ] [ 3/4 <hashtable> dup clone = ] unit-test

! Another crash discovered by erg
[ ] [
    H{ } clone
    [ 1 swap set-at ] catch drop
    [ 2 swap set-at ] catch drop
    [ 3 swap set-at ] catch drop
    drop
] unit-test

[ H{ { -1 4 } { -3 16 } { -5 36 } } ] [
    H{ { 1 2 } { 3 4 } { 5 6 } }
    [ >r neg r> sq ] assoc-map
] unit-test

! Bug discovered by littledan
[ { 5 5 5 5 } ] [
    [
        H{
            { 1 2 }
            { 2 3 }
            { 3 4 }
            { 4 5 }
            { 5 6 }
        } clone
        dup keys length ,
        dup assoc-size ,
        dup rehash
        dup keys length ,
        assoc-size ,
    ] { } make
] unit-test
