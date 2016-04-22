USING: compiler.tree.propagation.copy tools.test namespaces kernel
assocs ;
IN: compiler.tree.propagation.copy.tests

H{ } clone copies set

{ } [ 0 introduce-value ] unit-test
{ } [ 1 introduce-value ] unit-test
{ } [ 1 2 is-copy-of ] unit-test
{ } [ 2 3 is-copy-of ] unit-test
{ } [ 2 4 is-copy-of ] unit-test
{ } [ 4 5 is-copy-of ] unit-test
{ } [ 0 6 is-copy-of ] unit-test

{ 0 } [ 0 resolve-copy ] unit-test
{ 1 } [ 5 resolve-copy ] unit-test

! Make sure that we did path compression
{ 1 } [ 5 copies get at ] unit-test

{ 1 } [ 1 resolve-copy ] unit-test
{ 1 } [ 2 resolve-copy ] unit-test
{ 1 } [ 3 resolve-copy ] unit-test
{ 1 } [ 4 resolve-copy ] unit-test
{ 0 } [ 6 resolve-copy ] unit-test

{ 1234 } [
    H{ { 1234 1234 } } copies set 1234 resolve-copy
] unit-test
