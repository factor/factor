USING: alien.c-types ascii assocs kernel make math namespaces
sequences specialized-arrays tools.test ;
IN: assocs.tests
SPECIALIZED-ARRAY: double
IN: assocs.tests

{ t } [ H{ } dup assoc-subset? ] unit-test
{ f } [ H{ { 1 3 } } H{ } assoc-subset? ] unit-test
{ t } [ H{ } H{ { 1 3 } } assoc-subset? ] unit-test
{ t } [ H{ { 1 3 } } H{ { 1 3 } } assoc-subset? ] unit-test
{ f } [ H{ { 1 3 } } H{ { 1 "hey" } } assoc-subset? ] unit-test
{ f } [ H{ { 1 f } } H{ } assoc-subset? ] unit-test
{ t } [ H{ { 1 f } } H{ { 1 f } } assoc-subset? ] unit-test

! Test some combinators
{
    { 4 14 32 }
} [
    [
        H{
            { 1 2 }
            { 3 4 }
            { 5 6 }
        } [ * 2 + , ] assoc-each
    ] { } make
] unit-test

{ t } [ H{ } [ 2drop f ] assoc-all? ] unit-test
{ t } [ H{ { 1 1 } } [ = ] assoc-all? ] unit-test
{ f } [ H{ { 1 2 } } [ = ] assoc-all? ] unit-test
{ t } [ H{ { 1 1 } { 2 2 } } [ = ] assoc-all? ] unit-test
{ f } [ H{ { 1 2 } { 2 2 } } [ = ] assoc-all? ] unit-test

{ H{ } } [ H{ { t f } { f t } } [ 2drop f ] assoc-filter ] unit-test
{ H{ } } [ H{ { t f } { f t } } clone dup [ 2drop f ] assoc-filter! drop ] unit-test
{ H{ } } [ H{ { t f } { f t } } clone [ 2drop f ] assoc-filter! ] unit-test

{ H{ { 3 4 } { 4 5 } { 6 7 } } } [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop 3 >= ] assoc-filter
] unit-test

{ H{ { 3 4 } { 4 5 } { 6 7 } } } [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } } clone
    [ drop 3 >= ] assoc-filter!
] unit-test

{ H{ { 3 4 } { 4 5 } { 6 7 } } } [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } } clone dup
    [ drop 3 >= ] assoc-filter! drop
] unit-test

{ H{ { 1 2 } { 2 3 } } } [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } }
    [ drop 3 >= ] assoc-reject
] unit-test

{ H{ { 1 2 } { 2 3 } } } [
    H{ { 1 2 } { 2 3 } { 3 4 } { 4 5 } { 6 7 } } clone
    [ drop 3 >= ] assoc-reject!
] unit-test

{ 21 } [
    0 H{
        { 1 2 }
        { 3 4 }
        { 5 6 }
    } [
        + +
    ] assoc-each
] unit-test

H{ } clone "cache-test" set

{ 4 } [ 1 "cache-test" get [ 3 + ] cache ] unit-test
{ 5 } [ 2 "cache-test" get [ 3 + ] cache ] unit-test
{ 4 } [ 1 "cache-test" get [ 3 + ] cache ] unit-test
{ 5 } [ 2 "cache-test" get [ 3 + ] cache ] unit-test

{
    H{ { "factor" "rocks" } { 3 4 } }
} [
    H{ { "factor" "rocks" } { "dup" "sq" } { 3 4 } }
    H{ { "factor" "rocks" } { 1 2 } { 2 3 } { 3 4 } }
    assoc-intersect
] unit-test

{
    H{ { 1 2 } { 2 3 } { 6 5 } }
} [
    H{ { 2 4 } { 6 5 } } H{ { 1 2 } { 2 3 } }
    assoc-union
] unit-test

{
    H{ { 1 2 } { 2 3 } { 6 5 } }
} [
    H{ { 2 4 } { 6 5 } } clone dup H{ { 1 2 } { 2 3 } }
    assoc-union! drop
] unit-test

{
    H{ { 1 2 } { 2 3 } { 6 5 } }
} [
    H{ { 2 4 } { 6 5 } } clone H{ { 1 2 } { 2 3 } }
    assoc-union!
] unit-test

{ H{ { 1 2 } { 2 3 } } t } [
    f H{ { 1 2 } { 2 3 } } [ assoc-union ] 2keep swap assoc-union dupd =
] unit-test

{
    H{ { 1 f } }
} [
    H{ { 1 f } } H{ { 1 f } } assoc-intersect
] unit-test

{
    H{ { 3 4 } }
} [
    H{ { 1 2 } { 3 4 } } H{ { 1 3 } } assoc-diff
] unit-test

{
    H{ { 3 4 } }
} [
    H{ { 1 2 } { 3 4 } } clone dup H{ { 1 3 } } assoc-diff! drop
] unit-test

{
    H{ { 3 4 } }
} [
    H{ { 1 2 } { 3 4 } } clone H{ { 1 3 } } assoc-diff!
] unit-test

{ H{ { "hi" 2 } { 3 4 } } }
[ "hi" 1 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test

{ H{ { 1 2 } { 3 4 } } }
[ "hi" 5 H{ { 1 2 } { 3 4 } } clone [ rename-at ] keep ]
unit-test

{
    H{ { 1.0 1.0 } { 2.0 2.0 } }
} [
    double-array{ 1.0 2.0 } [ dup ] H{ } map>assoc
] unit-test

{
    { { 1.0 1.0 } { 2.0 2.0 } }
} [
    double-array{ 1.0 2.0 } [ dup ] map>alist
] unit-test

{ { 3 } } [
    [
        3
        H{ } clone
        2 [
            2dup [ , f ] cache drop
        ] times
        2drop
    ] { } make
] unit-test

{
    H{
        { "bangers" "mash" }
        { "fries" "onion rings" }
    }
} [
    { "bangers" "fries" } H{
        { "fish" "chips" }
        { "bangers" "mash" }
        { "fries" "onion rings" }
        { "nachos" "cheese" }
    } extract-keys
] unit-test

{ H{ { "b" [ 2 ] } { "d" [ 4 ] } } H{ { "a" [ 1 ] } { "c" [ 3 ] } } } [
    H{
        { "a" [ 1 ] }
        { "b" [ 2 ] }
        { "c" [ 3 ] }
        { "d" [ 4 ] }
    } [ nip first even? ] assoc-partition
] unit-test

{ 1 f } [ 1 H{ } ?at ] unit-test
{ 2 t } [ 1 H{ { 1 2 } } ?at ] unit-test

{ f } [ 1 2 H{ { 2 1 } } maybe-set-at ] unit-test
{ t } [ 1 3 H{ { 2 1 } } clone maybe-set-at ] unit-test
{ t } [ 3 2 H{ { 2 1 } } clone maybe-set-at ] unit-test

{ H{ { 1 2 } { 2 3 } } } [
    {
        H{ { 1 3 } }
        H{ { 2 3 } }
        H{ { 1 2 } }
    } assoc-union-all
] unit-test

{ H{ { 1 7 } } } [
    {
        H{ { 1 2 } { 2 4 } { 5 6 } }
        H{ { 1 3 } { 2 5 } }
        H{ { 1 7 } { 5 6 } }
    } assoc-intersect-all
] unit-test

{ f } [ "a" { } assoc-stack ] unit-test
{ 1 } [ "a" { H{ { "a" 1 } } H{ { "b" 2 } } } assoc-stack ] unit-test
{ 2 } [ "b" { H{ { "a" 1 } } H{ { "b" 2 } } } assoc-stack ] unit-test
{ f } [ "c" { H{ { "a" 1 } } H{ { "b" 2 } } } assoc-stack ] unit-test
{ f } [ "c" { H{ { "a" 1 } } H{ { "b" 2 } } H{ { "a" 3 } } } assoc-stack ] unit-test

{
    { { 1 f } }
} [
    { { 1 f } { f 2 } } sift-keys
] unit-test

{
    {
        { { 2 } 1 }
    }
} [
    {
        { { 2 } 1 }
        { { } 3 }
    } harvest-keys
] unit-test

{
    {
        { 1 { 2 } }
    }
} [
    {
        { 1 { 2 } }
        { 3 { } }
    } harvest-values
] unit-test

{
    { { f 2 } }
} [
    { { 1 f } { f 2 } } sift-values
] unit-test

! zip, zip-as
{
    { { 1 4 } { 2 5 } { 3 6 } }
} [ { 1 2 3 } { 4 5 6 } zip ] unit-test

{
    { { 1 4 } { 2 5 } { 3 6 } }
} [ V{ 1 2 3 } { 4 5 6 } zip ] unit-test

{
    { { 1 4 } { 2 5 } { 3 6 } }
} [ { 1 2 3 } { 4 5 6 } { } zip-as ] unit-test

{
    { { 1 4 } { 2 5 } { 3 6 } }
} [ B{ 1 2 3 } { 4 5 6 } { } zip-as ] unit-test

{
    V{ { 1 4 } { 2 5 } { 3 6 } }
} [ { 1 2 3 } { 4 5 6 } V{ } zip-as ] unit-test

{
    V{ { 1 4 } { 2 5 } { 3 6 } }
} [ BV{ 1 2 3 } BV{ 4 5 6 } V{ } zip-as ] unit-test

{ { { 1 3 } { 2 4 } }
} [ { 1 2 } { 3 4 } { } zip-as ] unit-test

{
    V{ { 1 3 } { 2 4 } }
} [ { 1 2 } { 3 4 } V{ } zip-as ] unit-test

{
    H{ { 1 3 } { 2 4 } }
} [ { 1 2 } { 3 4 } H{ } zip-as ] unit-test

! zip-index, zip-index-as
{
    { { 11 0 } { 22 1 } { 33 2 } }
} [ { 11 22 33 } zip-index ] unit-test

{
    { { 11 0 } { 22 1 } { 33 2 } }
} [ V{ 11 22 33 } zip-index ] unit-test

{
    { { 11 0 } { 22 1 } { 33 2 } }
} [ { 11 22 33 } { } zip-index-as ] unit-test

{
    { { 11 0 } { 22 1 } { 33 2 } }
} [ V{ 11 22 33 } { } zip-index-as ] unit-test

{
    V{ { 11 0 } { 22 1 } { 33 2 } }
} [ { 11 22 33 } V{ } zip-index-as ] unit-test

! zip-with, zip-with-as
{
    { { "cat" 3 } { "food" 4 } { "is" 2 } { "yummy" 5 } }
} [
    { "cat" "food" "is" "yummy" } [ length ] zip-with
] unit-test

{
    H{ { "cat" 3 } { "food" 4 } { "is" 2 } { "yummy" 5 } }
} [
    { "cat" "food" "is" "yummy" } [ length ] H{ } zip-with-as
] unit-test

{
    H{
        { 0 V{ 0 3 6 9 } }
        { 1 V{ 1 4 7 } }
        { 2 V{ 2 5 8 } }
    }
} [
    10 <iota> [ 3 mod ] collect-by
] unit-test

{
    H{
        { 0 V{ 0 3 6 9 0 3 6 9 } }
        { 1 V{ 1 4 7 1 4 7 } }
        { 2 V{ 2 5 8 2 5 8 } }
    }
} [
    10 <iota> [ 3 mod ] collect-by
    10 <iota> [ 3 mod ] collect-by!
] unit-test

{ H{ { 1 4 } } } [ H{ { 1 2 } } 1 over [ sq ] ?change-at ] unit-test
{ H{ { 1 2 } } } [ H{ { 1 2 } } 2 over [ sq ] ?change-at ] unit-test
{ H{ { 1 3 } } } [ H{ { 1 2 } } 3 1 pick [ drop dup ] ?change-at drop ] unit-test

{ H{ } 4 t } [ H{ { 1 4 } } 1 over delete-at* ] unit-test
{ H{ { 1 4 } } f f } [ H{ { 1 4 } } 3 over delete-at* ] unit-test

{ H{ } 4 t } [ H{ { 1 4 } } 1 over ?delete-at ] unit-test
{ H{ { 1 4 } } 3 f } [ H{ { 1 4 } } 3 over ?delete-at ] unit-test

{ t } [ H{ } assoc-empty? ] unit-test
{ f } [ H{ { 1 2 } } assoc-empty? ] unit-test

{ t } [ H{ { 1 2 } } H{ { 1 2 } } assoc= ] unit-test
{ f } [ H{ { 1 2 } } { } assoc= ] unit-test
{ t } [ H{ { 1 2 } } { { 1 2 } } assoc= ] unit-test

{ f f f } [ { } [ "impossible" ] assoc-find ] unit-test
{ 1 0 t } [ { { 1 0 } { 4 5 } } [ > ] assoc-find ] unit-test

{ { 1 2 } } [ { 1 2 } H{ } substitute ] unit-test
{ { 5 2 10 } } [ { 1 2 3 } H{ { 1 5 } { 3 10 } } substitute ] unit-test
{ { 2 3 3 } } [ { 1 2 3 } H{ { 1 2 } { 2 3 } } substitute ] unit-test

{ H{ { "foo" 4 } } } [
   H{ { "foo" 3 } } "foo" over inc-at
] unit-test
{ H{ { "foo" 3 } { "bar" 1 } } } [
   H{ { "foo" 3 }  } "bar" over inc-at
] unit-test

{ H{ { "foo" 4 } } } [
   H{ { "foo" 2 } } dup
   '[ 2 "foo" _ at+ ] call
] unit-test
{ H{ { "foo" 3 } { "bar" 5 } } } [
   H{ { "foo" 3 } } dup
   '[ 5 "bar" _ at+ ] call
] unit-test

{ 2 t } [ 5 H{ { 2 5 } } ?value-at ] unit-test
{ 10 f } [ 10 H{ { 2 5 } } ?value-at ] unit-test

{ H{ { 5 10  } } t } [
    H{ { 5 1 } } dup
    '[ 10 5 _  maybe-set-at ] call
] unit-test

{ H{ { 1 2 } { 5 10 } } t } [
    H{ { 1 2 } } dup
    '[ 10 5 _  maybe-set-at ] call
] unit-test

{ H{ { 1 2 } } f } [
    H{ { 1 2 } } dup
    '[ 2 1 _  maybe-set-at ] call
] unit-test

{ H{ { { 1 2 } 3 } } 3 } [
    H{ } dup '[ 1 2 _ [ + ] 2cache ] call
] unit-test
