USING: money parser tools.test eval ;
IN: money.tests

{ -1/10 } [ DECIMAL: -.1 ] unit-test
{ -1/10 } [ DECIMAL: -0.1 ] unit-test
{ -1/10 } [ DECIMAL: -00.10 ] unit-test

{ 0 } [ DECIMAL: .0 ] unit-test
{ 0 } [ DECIMAL: 0.0 ] unit-test
{ 0 } [ DECIMAL: 0. ] unit-test
{ 0 } [ DECIMAL: 0 ] unit-test
{ 1/10 } [ DECIMAL: .1 ] unit-test
{ 1/10 } [ DECIMAL: 0.1 ] unit-test
{ 1/10 } [ DECIMAL: 00.10 ] unit-test
{ 23 } [ DECIMAL: 23 ] unit-test
{ -23 } [ DECIMAL: -23 ] unit-test
{ -23-1/100 } [ DECIMAL: -23.01 ] unit-test

[ "DECIMAL: ." eval ] must-fail
[ "DECIMAL: f" eval ] must-fail
[ "DECIMAL: 0.f" eval ] must-fail
[ "DECIMAL: f.0" eval ] must-fail

{ "$100.00" } [ DECIMAL: 100.0 money>string ] unit-test
{ "$0.00" } [ DECIMAL: 0.0 money>string ] unit-test
