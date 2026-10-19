USING: math math.parser.integer-float tools.test ;
IN: math.parser.integer-float.tests

{ 0 } [ 0 1 ratio>binary64-bits ] unit-test
{ 0x3ff0000000000000 } [ 1 1 ratio>binary64-bits ] unit-test
{ 0x3ff8000000000000 } [ 3 2 ratio>binary64-bits ] unit-test
{ 0x3fb999999999999a } [ 1 10 ratio>binary64-bits ] unit-test
{ 0x3ff0000000000000 } [ 53 2^ 1 + 53 2^ ratio>binary64-bits ] unit-test
{ 0x3ff0000000000002 } [ 53 2^ 3 + 53 2^ ratio>binary64-bits ] unit-test
{ 1 } [ 1 1074 2^ ratio>binary64-bits ] unit-test
{ 0 } [ 1 1075 2^ ratio>binary64-bits ] unit-test
{ 2 } [ 3 1075 2^ ratio>binary64-bits ] unit-test
{ 0x0010000000000000 } [ 1 1022 2^ ratio>binary64-bits ] unit-test
{ 0x7ff0000000000000 } [ 1024 2^ 1 ratio>binary64-bits ] unit-test
{ 0x4029000000000000 } [ 125 10 -1 scaled-integer>binary64-bits ] unit-test
{ 0x409f400000000000 } [ 125 2 4 scaled-integer>binary64-bits ] unit-test
