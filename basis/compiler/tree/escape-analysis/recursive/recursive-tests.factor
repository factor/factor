USING: kernel tools.test namespaces sequences math
compiler.tree.escape-analysis.recursive
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.recursive.tests

H{ } clone allocations set
<escaping-values> escaping-values set

{ } [ 8 [ introduce-value ] each-integer ] unit-test

{ } [ { 1 2 } 3 record-allocation ] unit-test

{ t } [ { 1 2 } { 6 7 } congruent? ] unit-test
{ f } [ { 3 4 } { 6 7 } congruent? ] unit-test
{ f } [ { 3 4 5 } { 6 7 } congruent? ] unit-test
