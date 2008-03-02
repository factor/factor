USING: money parser tools.test ;
IN: money.tests

[ -1/10 ] [ DECIMAL: -.1 ] unit-test
[ -1/10 ] [ DECIMAL: -0.1 ] unit-test
[ -1/10 ] [ DECIMAL: -00.10 ] unit-test

[ 0 ] [ DECIMAL: .0 ] unit-test
[ 0 ] [ DECIMAL: 0.0 ] unit-test
[ 0 ] [ DECIMAL: 0. ] unit-test
[ 0 ] [ DECIMAL: 0 ] unit-test
[ 1/10 ] [ DECIMAL: .1 ] unit-test
[ 1/10 ] [ DECIMAL: 0.1 ] unit-test
[ 1/10 ] [ DECIMAL: 00.10 ] unit-test



[ "DECIMAL: ." eval ] must-fail
[ "DECIMAL: f" eval ] must-fail
[ "DECIMAL: 0.f" eval ] must-fail
[ "DECIMAL: f.0" eval ] must-fail
