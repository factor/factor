USING: kernel math.functions tools.test ;
IN: math.factorials

[ 1 ] [ -1 factorial ] unit-test ! not necessarily correct
[ 1 ] [ 0 factorial ] unit-test
[ 1 ] [ 1 factorial ] unit-test
[ 3628800 ] [ 10 factorial ] unit-test

{ 1 } [ 10 10 factorial/ ] unit-test
{ 720 } [ 10 7 factorial/ ] unit-test
{ 604800 } [ 10 3 factorial/ ] unit-test
{ 3628800 } [ 10 0 factorial/ ] unit-test

{ 17160 } [ 10 4 rising-factorial ] unit-test
{ 1/57120 } [ 10 -4 rising-factorial ] unit-test
{ 10 } [ 10 1 rising-factorial ] unit-test
{ 0 } [ 10 0 rising-factorial ] unit-test

{ 5040 } [ 10 4 falling-factorial ] unit-test
{ 1/24024 } [ 10 -4 falling-factorial ] unit-test
{ 10 } [ 10 1 falling-factorial ] unit-test
{ 0 } [ 10 0 falling-factorial ] unit-test

{ 7301694400 } [ 100 5 3 factorial-power ] unit-test
{ 5814000000 } [ 100 5 5 factorial-power ] unit-test
{ 4549262400 } [ 100 5 7 factorial-power ] unit-test
{ 384000000 } [ 100 5 20 factorial-power ] unit-test
{ 384000000 } [ 100 5 20 factorial-power ] unit-test
{ 44262400 } [ 100 5 24 factorial-power ] unit-test
{ 0 } [ 100 5 25 factorial-power ] unit-test
{ 4760 } [ 20 3 3 factorial-power ] unit-test
{ 1/17342 } [ 20 -3 3 factorial-power ] unit-test
{ 1/2618 } [ 20 -3 -3 factorial-power ] unit-test
{ 11960 } [ 20 3 -3 factorial-power ] unit-test
{ t } [ 20 3 [ 1 factorial-power ] [ falling-factorial ] 2bi = ] unit-test
{ t } [ 20 3 [ 0 factorial-power ] [ ^ ] 2bi = ] unit-test
