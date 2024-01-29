USING: arrays kernel math math.combinatorics
math.combinatorics.private tools.test sequences sets ;

{ 1 } [ -1 factorial ] unit-test ! required by other math.combinatorics words
{ 1 } [ 0 factorial ] unit-test
{ 1 } [ 1 factorial ] unit-test
{ 3628800 } [ 10 factorial ] unit-test

{ 1 } [ 3 0 nPk ] unit-test
{ 6 } [ 3 2 nPk ] unit-test
{ 6 } [ 3 3 nPk ] unit-test
{ 0 } [ 3 4 nPk ] unit-test
{ 311875200 } [ 52 5 nPk ] unit-test
{ 672151459757865654763838640470031391460745878674027315200000000000 } [ 52 47 nPk ] unit-test

{ 1 } [ 3 0 nCk ] unit-test
{ 3 } [ 3 2 nCk ] unit-test
{ 1 } [ 3 3 nCk ] unit-test
{ 0 } [ 3 4 nCk ] unit-test
{ 2598960 } [ 52 5 nCk ] unit-test
{ 2598960 } [ 52 47 nCk ] unit-test


{ { } } [ 0 factoradic ] unit-test
{ { 1 0 } } [ 1 factoradic ] unit-test
{ { 1 1 0 3 0 1 0 } } [ 859 factoradic ] unit-test

{ { 0 1 2 3 } } [ { 0 0 0 0 } >permutation ] unit-test
{ { 0 1 3 2 } } [ { 0 0 1 0 } >permutation ] unit-test
{ { 1 2 0 6 3 5 4 } } [ { 1 1 0 3 0 1 0 } >permutation ] unit-test

{ { 0 1 2 3 } } [ 0 4 <iota> permutation-indices ] unit-test
{ { 0 1 3 2 } } [ 1 4 <iota> permutation-indices ] unit-test
{ { 1 2 0 6 3 5 4 } } [ 859 7 <iota> permutation-indices ] unit-test

{ { "a" "b" "c" "d" } } [ 0 { "a" "b" "c" "d" } permutation ] unit-test
{ { "d" "c" "b" "a" } } [ 23 { "a" "b" "c" "d" } permutation ] unit-test
{ { "d" "a" "b" "c" } } [ 18 { "a" "b" "c" "d" } permutation ] unit-test

{ { { "a" "b" "c" } { "a" "c" "b" }
    { "b" "a" "c" } { "b" "c" "a" }
    { "c" "a" "b" } { "c" "b" "a" } } } [ { "a" "b" "c" } all-permutations ] unit-test

{ { 0 1 2 } } [ { "a" "b" "c" } inverse-permutation ] unit-test
{ { 2 1 0 } } [ { "c" "b" "a" } inverse-permutation ] unit-test
{ { 3 0 2 1 } } [ { 12 45 34 2 } inverse-permutation ] unit-test

{ "" } [ "" next-permutation ] unit-test
{ "1" } [ "1" next-permutation ] unit-test
{ "21" } [ "12" next-permutation ] unit-test
{ "8344112666" } [ "8342666411" next-permutation ] unit-test
{ "ABC" "ACB" "BAC" "BCA" "CAB" "CBA" "ABC" }
[ "ABC" 6 [ dup dup clone-like next-permutation ] times ] unit-test

{ { "AA" "AB" "AC" "BB" "BC" "CC" } } [ "ABC" 2 all-combinations-with-replacement ] unit-test

{ { 0 1 2 } } [ 0 3 5 combination-indices ] unit-test
{ { 2 3 4 } } [ 9 3 5 combination-indices ] unit-test

{ { "a" "b" "c" } } [ 0 { "a" "b" "c" "d" "e" } 3 combination ] unit-test
{ { "c" "d" "e" } } [ 9 { "a" "b" "c" "d" "e" } 3 combination ] unit-test

{ { { "a" "b" } { "a" "c" }
    { "a" "d" } { "b" "c" }
    { "b" "d" } { "c" "d" } } } [ { "a" "b" "c" "d" } 2 all-combinations ] unit-test

{ { { } } } [ { } all-subsets ] unit-test

{ { { } { 1 } { 2 } { 3 } { 1 2 } { 1 3 } { 2 3 } { 1 2 3 } } }
[ { 1 2 3 } all-subsets ] unit-test

{ { } } [ { 1 2 } 0 all-selections ] unit-test

{ { { 1 } { 2 } } } [ { 1 2 } 1 all-selections ] unit-test
{ { { { 1 } } { 2 } } } [ { { 1 } 2 } 1 all-selections ] unit-test

{ { { 1 1 } { 1 2 } { 2 1 } { 2 2 } } }
[ { 1 2 } 2 all-selections ] unit-test

{ { { 1 1 1 } { 1 1 2 } { 1 2 1 } { 1 2 2 }
    { 2 1 1 } { 2 1 2 } { 2 2 1 } { 2 2 2 } } }
[ { 1 2 } 3 all-selections ] unit-test

{ { "aa" "ab" "ac" "ba" "bb" "bc" "ca" "cb" "cc" } }
[ "abc" 2 all-selections ] unit-test

{ V{ { 1 2 } { 1 3 } } }
[ { 1 2 3 } 2 [ { 1 } head? ] filter-combinations ] unit-test

{ { 3 4 5 } }
[ { 1 2 3 } 2 [ sum ] map-combinations ] unit-test

{ V{ { 1 2 3 } { 1 3 2 } } }
[ { 1 2 3 } [ { 1 } head? ] filter-permutations ] unit-test

{ { 6 6 6 6 6 6 } }
[ { 1 2 3 } [ sum ] map-permutations ] unit-test

{ f } [ { 1 2 3 } 2 [ last 4 = ] find-combination ] unit-test
{ { 2 3 } } [ { 1 2 3 } 2 [ first 2 = ] find-combination ] unit-test

{ f } [ { 1 2 3 } [ last 4 = ] find-permutation ] unit-test
{ { 2 1 3 } } [ { 1 2 3 } [ first 2 = ] find-permutation ] unit-test

{ t } [
    { 1 1 1 1 1 1 1 1 2 }
    [ all-permutations members ] [ all-unique-permutations ] bi =
] unit-test

{ { { 0 1 2 } { 0 2 1 } { 1 0 2 } { 1 2 0 } { 2 0 1 } { 2 1 0 } } }
[ 3 <iota> <permutations> >array ] unit-test

{ { "as" "ad" "af" "sa" "sd" "sf" "da" "ds" "df" "fa" "fs" "fd" } }
[ "asdf" 2 <k-permutations> >array ] unit-test

{ { "" } } [
    "asdf" 0 <k-permutations> >array
] unit-test

{ { } } [
    "" 10 <k-permutations>
] unit-test

{ { "" } } [
    "" 0 <k-permutations> >array
] unit-test
