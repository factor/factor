USING: compiler definitions generic assocs inference math
namespaces parser tools.test words kernel sequences arrays io
effects tools.test.inference ;
IN: temporary

DEFER: b
DEFER: c

[ ] [ "IN: temporary : a 1 2 ; : b a a ;" eval ] unit-test

[ 1 2 1 2 ] [ "USE: temporary b" eval ] unit-test

{ 0 4 } [ b ] unit-test-effect

[ ] [ "IN: temporary : a 1 2 3 ;" eval ] unit-test

[ 1 2 3 1 2 3 ] [ "USE: temporary b" eval ] unit-test

{ 0 6 } [ b ] unit-test-effect

\ b word-xt "b-xt" set

[ ] [ "IN: temporary : c b ;" eval ] unit-test

[ t ] [ "b-xt" get \ b word-xt = ] unit-test

\ c word-xt "c-xt" set

[ ] [ "IN: temporary : a 1 2 4 ;" eval ] unit-test

[ t ] [ "c-xt" get \ c word-xt = ] unit-test

[ 1 2 4 1 2 4 ] [ "USE: temporary c" eval ] unit-test

[ ] [ "IN: temporary : a 1 2 ;" eval ] unit-test

{ 0 4 } [ c ] unit-test-effect

[ f ] [ "c-xt" get \ c word-xt = ] unit-test

[ 1 2 1 2 ] [ "USE: temporary c" eval ] unit-test

[ ] [ "IN: temporary : d 3 ; inline" eval ] unit-test

[ ] [ "IN: temporary : e d d ;" eval ] unit-test

[ 3 3 ] [ "USE: temporary e" eval ] unit-test

[ ] [ "IN: temporary : d 4 ; inline" eval ] unit-test

[ 4 4 ] [ "USE: temporary e" eval ] unit-test
