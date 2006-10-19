USING: kernel test sequences sequences-internals circular ;

[ 0 ] [ { 0 1 2 3 4 } <circular> 0 swap circular@ drop ] unit-test
[ 2 ] [ { 0 1 2 3 4 } <circular> 2 swap circular@ drop ] unit-test

[ CHAR: t ] [ "test" <circular> 0 swap nth ] unit-test
[ "test"  ] [ "test" <circular> "" like ] unit-test

[ "test" <circular> 5 swap nth ] unit-test-fails
[ CHAR: e ] [ "test" <circular> 5 swap nth-unsafe ] unit-test
 
[ [ 1 2 3 ] ] [ { 1 2 3 } <circular> [ ] like ] unit-test
[ [ 2 3 1 ] ] [ { 1 2 3 } <circular> 1 over change-circular-start [ ] like ] unit-test
[ [ 3 1 2 ] ] [ { 1 2 3 } <circular> 1 over change-circular-start 1 over change-circular-start [ ] like ] unit-test

[ "fob" ] [ "foo" <circular> CHAR: b 2 pick set-nth "" like ] unit-test
[ "foo" <circular> CHAR: b 3 rot set-nth ] unit-test-fails
[ "boo" ] [ "foo" <circular> CHAR: b 3 pick set-nth-unsafe "" like ] unit-test
[ "ornact" ] [ "factor" <circular> 4 over change-circular-start CHAR: n 2 pick set-nth "" like ] unit-test

