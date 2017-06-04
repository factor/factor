USING: money parser tools.test eval ;
IN: money.tests

{ -1/10 } [ decimal: -.1 ] unit-test
{ -1/10 } [ decimal: -0.1 ] unit-test
{ -1/10 } [ decimal: -00.10 ] unit-test

{ 0 } [ decimal: .0 ] unit-test
{ 0 } [ decimal: 0.0 ] unit-test
{ 0 } [ decimal: 0. ] unit-test
{ 0 } [ decimal: 0 ] unit-test
{ 1/10 } [ decimal: .1 ] unit-test
{ 1/10 } [ decimal: 0.1 ] unit-test
{ 1/10 } [ decimal: 00.10 ] unit-test
{ 23 } [ decimal: 23 ] unit-test
{ -23 } [ decimal: -23 ] unit-test
{ -23-1/100 } [ decimal: -23.01 ] unit-test

[ "decimal: ." eval ] must-fail
[ "decimal: f" eval ] must-fail
[ "decimal: 0.f" eval ] must-fail
[ "decimal: f.0" eval ] must-fail

{ "$100.00" } [ decimal: 100.0 money>string ] unit-test
{ "$0.00" } [ decimal: 0.0 money>string ] unit-test

{ "$1.00" } [ 1.0 money>string ] unit-test
{ "$1.00" } [ 1 money>string ] unit-test
{ "$1.50" } [ 1+1/2 money>string ] unit-test
{ "$1.50" } [ 1.50 money>string ] unit-test
