USING: math.combinatorics math.combinatorics.private tools.test sequences ;
IN: math.combinatorics.tests

[ 1 ] [ 0 factorial ] unit-test
[ 1 ] [ 1 factorial ] unit-test
[ 3628800 ] [ 10 factorial ] unit-test

[ 1 ] [ 3 0 nPk ] unit-test
[ 6 ] [ 3 2 nPk ] unit-test
[ 6 ] [ 3 3 nPk ] unit-test
[ 0 ] [ 3 4 nPk ] unit-test
[ 311875200 ] [ 52 5 nPk ] unit-test
[ 672151459757865654763838640470031391460745878674027315200000000000 ] [ 52 47 nPk ] unit-test

[ 1 ] [ 3 0 nCk ] unit-test
[ 3 ] [ 3 2 nCk ] unit-test
[ 1 ] [ 3 3 nCk ] unit-test
[ 0 ] [ 3 4 nCk ] unit-test
[ 2598960 ] [ 52 5 nCk ] unit-test
[ 2598960 ] [ 52 47 nCk ] unit-test


[ { } ] [ 0 factoradic ] unit-test
[ { 1 0 } ] [ 1 factoradic ] unit-test
[ { 1 1 0 3 0 1 0 } ] [ 859 factoradic ] unit-test

[ { 0 1 2 3 } ] [ { 0 0 0 0 } >permutation ] unit-test
[ { 0 1 3 2 } ] [ { 0 0 1 0 } >permutation ] unit-test
[ { 1 2 0 6 3 5 4 } ] [ { 1 1 0 3 0 1 0 } >permutation ] unit-test

[ { 0 1 2 3 } ] [ 0 4 iota permutation-indices ] unit-test
[ { 0 1 3 2 } ] [ 1 4 iota permutation-indices ] unit-test
[ { 1 2 0 6 3 5 4 } ] [ 859 7 iota permutation-indices ] unit-test

[ { "a" "b" "c" "d" } ] [ 0 { "a" "b" "c" "d" } permutation ] unit-test
[ { "d" "c" "b" "a" } ] [ 23 { "a" "b" "c" "d" } permutation ] unit-test
[ { "d" "a" "b" "c" } ] [ 18 { "a" "b" "c" "d" } permutation ] unit-test

[ { { "a" "b" "c" } { "a" "c" "b" }
    { "b" "a" "c" } { "b" "c" "a" }
    { "c" "a" "b" } { "c" "b" "a" } } ] [ { "a" "b" "c" } all-permutations ] unit-test

[ { 0 1 2 } ] [ { "a" "b" "c" } inverse-permutation ] unit-test
[ { 2 1 0 } ] [ { "c" "b" "a" } inverse-permutation ] unit-test
[ { 3 0 2 1 } ] [ { 12 45 34 2 } inverse-permutation ] unit-test


[ 2598960 ] [ 52 iota 5 <combo> choose ] unit-test

[ 6 3 13 6 ] [ 7 4 28 next-values ] unit-test
[ 5 2 3 5 ] [ 6 3 13 next-values ] unit-test
[ 3 1 0 3 ] [ 5 2 3 next-values ] unit-test
[ 0 0 0 0 ] [ 3 1 0 next-values ] unit-test

[ 9 ] [ 0 5 iota 3 <combo> dual-index ] unit-test
[ 0 ] [ 9 5 iota 3 <combo> dual-index ] unit-test
[ 179 ] [ 72 10 iota 5 <combo> dual-index ] unit-test

[ { 5 3 2 1 } ] [ 7 4 <combo> 8 combinadic ] unit-test
[ { 4 3 2 1 0 } ] [ 10 iota 5 <combo> 0 combinadic ] unit-test
[ { 8 6 3 1 0 } ] [ 10 iota 5 <combo> 72 combinadic ] unit-test
[ { 9 8 7 6 5 } ] [ 10 iota 5 <combo> 251 combinadic ] unit-test

[ { 0 1 2 } ] [ 0 5 iota 3 <combo> combination-indices ] unit-test
[ { 2 3 4 } ] [ 9 5 iota 3 <combo> combination-indices ] unit-test

[ { "a" "b" "c" } ] [ 0 { "a" "b" "c" "d" "e" } 3 combination ] unit-test
[ { "c" "d" "e" } ] [ 9 { "a" "b" "c" "d" "e" } 3 combination ] unit-test

[ { { "a" "b" } { "a" "c" }
    { "a" "d" } { "b" "c" }
    { "b" "d" } { "c" "d" } } ] [ { "a" "b" "c" "d" } 2 all-combinations ] unit-test
