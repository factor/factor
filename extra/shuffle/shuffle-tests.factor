USING: kernel sequences.generalizations shuffle tools.test ;

{ 1 2 3 4 } [ 3 4 1 2 2swap ] unit-test

{ 4 2 3 } [ 1 2 3 4 shuffle( a b c d -- d b c ) ] unit-test

{ 2 3 4 5 1 } [ 1 2 3 4 5 5roll ] unit-test
{ 2 3 4 5 6 1 } [ 1 2 3 4 5 6 6roll ] unit-test
{ 2 3 4 5 6 7 1 } [ 1 2 3 4 5 6 7 7roll ] unit-test
{ 2 3 4 5 6 7 8 1 } [ 1 2 3 4 5 6 7 8 8roll ] unit-test

[ [ 1 2 3 ] 2 3 0 nrotated ] must-infer
[ [ 1 2 3 ] 2 3 0 -nrotated ] must-infer
{ 1 2 3 4 } [ 1 2 3 4  4 4 0 nrotated ] unit-test
{ 1 2 3 4 } [ 1 2 3 4  4 4 0 -nrotated ] unit-test
{ 3 1 2 4 } [ 1 2 3 4  1 3 1 -nrotated ] unit-test

{ 1 2 3  1 2 }
[ 1 2 3  2 1 0 noverd ] unit-test

{ 1 2 3  4 5 6 7 8  1 2 3  9 }
[ 1 2 3  4 5 6 7 8  9  3 5 1 noverd ] unit-test

{ t }
[
    1 2 3 4 5 6 7   8 9    3 2  ntuckd 10 narray
    1 2 3 4 5 6 7   8 9  1 3 2 mntuckd 10 narray =
] unit-test

{ 1  4 5  2 3  4 5  6 7 }
[ 1 2 3 4 5 6 7  2 4 2 mntuckd ] unit-test

{ 1 2 3 4 2 3 4 5 6 5 6 7 }
[ 1 2 3 4 5 6 7  5 2 1 mntuckd ] unit-test

{ 4 5 6 7  0 1 2 3 4 5 6 7 8 9 } [
    0 1 2 3   4 5 6 7   8 9
    4 8 2 mntuckd
] unit-test

{ 1 2 3 5 4 } [ 1 2 3 4 5  2 0 -nrotd ] unit-test
{ 1 2 4 3 5 } [ 1 2 3 4 5  2 1 -nrotd ] unit-test
{ 1 3 2 4 5 } [ 1 2 3 4 5  2 2 -nrotd ] unit-test
{ 2 1 3 4 5 } [ 1 2 3 4 5  2 3 -nrotd ] unit-test

{ 1 2 3 5 4 } [ 1 2 3 4 5  2 0  nrotd ] unit-test
{ 1 2 4 3 5 } [ 1 2 3 4 5  2 1  nrotd ] unit-test
{ 1 3 2 4 5 } [ 1 2 3 4 5  2 2  nrotd ] unit-test
{ 2 1 3 4 5 } [ 1 2 3 4 5  2 3  nrotd ] unit-test

{ 1 2 5 3 4 } [ 1 2 3 4 5  3 0 -nrotd ] unit-test
{ 1 2 5 3 4 } [ 1 2 3 4 5  -3 0 nrotd ] unit-test
{ 1 4 2 3 5 } [ 1 2 3 4 5  3 1 -nrotd ] unit-test
{ 1 4 2 3 5 } [ 1 2 3 4 5  -3 1 nrotd ] unit-test
{ 3 1 2 4 5 } [ 1 2 3 4 5  3 2 -nrotd ] unit-test
{ 3 1 2 4 5 } [ 1 2 3 4 5  -3 2 nrotd ] unit-test

{ 1 2 4 5 3 } [ 1 2 3 4 5  3 0 nrotd ] unit-test
{ 1 2 4 5 3 } [ 1 2 3 4 5  -3 0 -nrotd ] unit-test
{ 1 3 4 2 5 } [ 1 2 3 4 5  3 1 nrotd ] unit-test
{ 1 3 4 2 5 } [ 1 2 3 4 5  -3 1 -nrotd ] unit-test
{ 2 3 1 4 5 } [ 1 2 3 4 5  3 2 nrotd ] unit-test
{ 2 3 1 4 5 } [ 1 2 3 4 5  -3 2 -nrotd ] unit-test
