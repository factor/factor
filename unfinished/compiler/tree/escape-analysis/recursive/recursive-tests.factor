IN: compiler.tree.escape-analysis.recursive.tests
USING: kernel tools.test namespaces sequences
compiler.tree.copy-equiv
compiler.tree.escape-analysis.recursive
compiler.tree.escape-analysis.allocations ;

H{ } clone allocations set
H{ } clone copies set

[ ] [ 8 [ introduce-value ] each ] unit-test

[ ] [ { 1 2 } 3 record-allocation ] unit-test

[ t ] [ { 1 2 } { 6 7 } congruent? ] unit-test
[ f ] [ { 3 4 } { 6 7 } congruent? ] unit-test
[ f ] [ { 3 4 5 } { 6 7 } congruent? ] unit-test
