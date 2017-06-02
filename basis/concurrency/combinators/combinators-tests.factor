USING: concurrency.combinators tools.test random kernel math
concurrency.mailboxes threads sequences accessors arrays
math.parser ;
IN: concurrency.combinators.tests

[ [ drop ] parallel-each ] must-infer
{ 2 0 } [ [ 2drop ] 2parallel-each ] must-infer-as
[ [ ] parallel-map ] must-infer
{ 2 1 } [ [ 2array ] 2parallel-map ] must-infer-as
[ [ ] parallel-filter ] must-infer

{ { 1 4 9 } } [ { 1 2 3 } [ sq ] parallel-map ] unit-test

{ { 1 4 9 } } [ { 1 2 3 } [ 1000000 random sleep sq ] parallel-map ] unit-test

[ { 1 2 3 } [ dup 2 mod 0 = [ "Even" throw ] when ] parallel-map ]
[ error>> "Even" = ] must-fail-with

{ V{ 0 3 6 9 } }
[ 10 <iota> [ 3 mod zero? ] parallel-filter ] unit-test

{ 10 }
[
    V{ } clone
    10 <iota> over [ push ] curry parallel-each
    length
] unit-test

{ { 10 20 30 } } [
    { 1 4 3 } { 10 5 10 } [ * ] 2parallel-map
] unit-test

{ { -9 -1 -7 } } [
    { 1 4 3 } { 10 5 10 } [ - ] 2parallel-map
] unit-test

[
    { 1 4 3 } { 1 0 1 } [ / drop ] 2parallel-each
] must-fail

{ 20 }
[
    V{ } clone
    10 <iota> 10 <iota> pick [ [ push ] [ push ] bi ] curry 2parallel-each
    length
] unit-test

[ { f } [ "OOPS" throw ] parallel-each ] must-fail

{ "1a" "4b" "3c" } [
    2
    { [ 1 - ] [ sq ] [ 1 + ] } parallel-cleave
    [ number>string ] 3 parallel-napply
    { [ "a" append ] [ "b" append ] [ "c" append ] } parallel-spread
] unit-test

{ H{ { 0 4 } { 2 6 } { 4 8 } } } [
    H{ { 1 2 } { 3 4 } { 5 6 } } [
        [ 1 - ] [ 2 + ] bi*
    ] parallel-assoc-map
] unit-test
