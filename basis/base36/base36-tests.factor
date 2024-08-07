USING: base36 math.parser strings tools.test ;

{ "" } [ "" >base36 >string ] unit-test
{ "" } [ "" base36> >string ] unit-test

{ "0" } [ B{ 0 } >base36 >string ] unit-test
{ B{ 0 } } [ "0" base36> ] unit-test

{ "00" } [ B{ 0 0 } >base36 >string ] unit-test
{ B{ 0 0 } } [ "00" base36> ] unit-test

{ "ZIK0ZJ" } [ 2147483647 n>base36 >string ] unit-test
{ 2147483647 } [ "ZIK0ZJ" base36>n ] unit-test

{ "1Y2P0IJ32E8E7" } [ 9223372036854775807 n>base36 >string ] unit-test
{ 9223372036854775807 } [ "1Y2P0IJ32E8E7" base36>n ] unit-test
