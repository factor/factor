USING: stack-checker.call-effect tools.test math kernel math effects ;
IN: stack-checker.call-effect.tests

[ t ] [ \ + (( a b -- c )) execute-effect-unsafe? ] unit-test
[ t ] [ \ + (( a b c -- d e )) execute-effect-unsafe? ] unit-test
[ f ] [ \ + (( a b c -- d )) execute-effect-unsafe? ] unit-test
[ f ] [ \ call (( x -- )) execute-effect-unsafe? ] unit-test

[ t ] [ [ + ] cached-effect (( a b -- c )) effect= ] unit-test
[ t ] [ 5 [ + ] curry cached-effect (( a -- c )) effect= ] unit-test
[ t ] [ 5 [ ] curry cached-effect (( -- c )) effect= ] unit-test
[ t ] [ [ dup ] [ drop ] compose cached-effect (( a -- b )) effect= ] unit-test
[ t ] [ [ drop ] [ dup ] compose cached-effect (( a b -- c d )) effect= ] unit-test
[ t ] [ [ 2drop ] [ dup ] compose cached-effect (( a b c -- d e )) effect= ] unit-test
[ t ] [ [ 1 2 3 ] [ 2drop ] compose cached-effect (( -- a )) effect= ] unit-test
[ t ] [ [ 1 2 ] [ 3drop ] compose cached-effect (( a -- )) effect= ] unit-test