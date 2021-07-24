USING: accessors assocs continuations hashtables kernel make
math namespaces sequences tools.test ;

{ H{ } } [ { } [ dup ] H{ } map>assoc ] unit-test

{ } [ 1000 <iota> [ dup sq ] H{ } map>assoc "testhash" set ] unit-test

{ V{ } }
[ 1000 <iota> [ dup sq swap "testhash" get at = ] reject ]
unit-test

{ t }
[ "testhash" get hashtable? ]
unit-test

{ f }
[ { 1 { 2 3 } } hashtable? ]
unit-test

{ t } [
    "value" "key"
    [ associate ] [ H{ } clone [ set-at ] keep ] 2bi
    [ = ] [ [ array>> length ] bi@ = ] 2bi and
] unit-test

! Test some hashcodes.

{ t } [ [ 1 2 3 ] hashcode [ 1 2 3 ] hashcode = ] unit-test
{ t } [ [ 1 [ 2 3 ] 4 ] hashcode [ 1 [ 2 3 ] 4 ] hashcode = ] unit-test

{ t } [ 12 hashcode 12 hashcode = ] unit-test
{ t } [ 12 >bignum hashcode 12 hashcode = ] unit-test

! Test various odd keys to see if they work.

16 <hashtable> "testhash" set

t { 2 3 } "testhash" get set-at
f 100000000000000000000000000 "testhash" get set-at
{ } { [ { } ] } "testhash" get set-at

{ t } [ { 2 3 } "testhash" get at ] unit-test
{ f } [ 100000000000000000000000000 "testhash" get at* drop ] unit-test
{ { } } [ { [ { } ] } clone "testhash" get at* drop ] unit-test

! Regression
3 <hashtable> "broken-remove" set
1 W{ \ + } dup "x" set "broken-remove" get set-at
2 W{ \ = } dup "y" set "broken-remove" get set-at
"x" get "broken-remove" get delete-at
2 "y" get "broken-remove" get set-at
{ 1 } [ "broken-remove" get keys length ] unit-test

{
    { "salmon" "fish" }
    { "crocodile" "reptile" }
    { "cow" "mammal" }
    { "visual basic" "language" }
} >hashtable "testhash" set

{ f f } [
    "visual basic" "testhash" get delete-at
    "visual basic" "testhash" get at*
] unit-test

{ t } [ H{ } dup = ] unit-test
{ f } [ "xyz" H{ } = ] unit-test
{ t } [ H{ } H{ } = ] unit-test
{ f } [ H{ { 1 3 } } H{ } = ] unit-test
{ f } [ H{ } H{ { 1 3 } } = ] unit-test
{ t } [ H{ { 1 3 } } H{ { 1 3 } } = ] unit-test
{ f } [ H{ { 1 3 } } H{ { 1 "hey" } } = ] unit-test

! Testing the hash element counting

H{ } clone "counting" set
"value" "key" "counting" get set-at
{ 1 } [ "counting" get assoc-size ] unit-test
"value" "key" "counting" get set-at
{ 1 } [ "counting" get assoc-size ] unit-test
"key" "counting" get delete-at
{ 0 } [ "counting" get assoc-size ] unit-test
"key" "counting" get delete-at
{ 0 } [ "counting" get assoc-size ] unit-test

! Test rehashing

2 <hashtable> "rehash" set

1 1 "rehash" get set-at
2 2 "rehash" get set-at
3 3 "rehash" get set-at
4 4 "rehash" get set-at
5 5 "rehash" get set-at
6 6 "rehash" get set-at

{ 6 } [ "rehash" get assoc-size ] unit-test

{ 6 } [ "rehash" get clone assoc-size ] unit-test

"rehash" get clear-assoc

{ 0 } [ "rehash" get assoc-size ] unit-test

{
    3
} [
    2 H{
        { 1 2 }
        { 2 3 }
    } clone at
] unit-test

! There was an assoc in place of assoc* somewhere
3 <hashtable> "f-hash-test" set

10 [ f f "f-hash-test" get set-at ] times

{ 1 } [ "f-hash-test" get assoc-size ] unit-test

! Resource leak...
H{ } "x" set
100 [ drop "x" get clear-assoc ] each-integer

! non-integer capacity not allowed
[ 0.75 <hashtable> ] must-fail

! Another crash discovered by erg
{ } [
    H{ } clone
    [ 1 swap set-at ] ignore-errors
    [ 2 swap set-at ] ignore-errors
    [ 3 swap set-at ] ignore-errors
    drop
] unit-test

{ H{ { -1 4 } { -3 16 } { -5 36 } } } [
    H{ { 1 2 } { 3 4 } { 5 6 } }
    [ [ neg ] dip sq ] assoc-map
] unit-test

! make sure growth and capacity use same load-factor
{ t } [
    100 <iota>
    [ [ <hashtable> ] map ]
    [ [ H{ } clone [ '[ dup _ set-at ] each-integer ] keep ] map ] bi
    [ [ array>> length ] bi@ = ] 2all?
] unit-test

! Bug discovered by littledan
{ { 5 5 5 5 } } [
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

{ { "one" "two" 3 } } [
    { 1 2 3 } H{ { 1 "one" } { 2 "two" } } substitute
] unit-test

! We want this to work
{ } [ hashtable new "h" set ] unit-test

{ 0 } [ "h" get assoc-size ] unit-test

{ f f } [ "goo" "h" get at* ] unit-test

{ } [ 1 2 "h" get set-at ] unit-test

{ 1 } [ "h" get assoc-size ] unit-test

{ 1 } [ 2 "h" get at ] unit-test

! Random test case
{ "A" } [ 100 <iota> [ dup ] H{ } map>assoc 32 over delete-at "A" 32 pick set-at 32 of ] unit-test
