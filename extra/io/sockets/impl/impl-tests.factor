USING: io.sockets.impl io.sockets kernel tools.test ;
IN: temporary

[ B{ 1 2 3 4 } ]
[ "1.2.3.4" T{ inet4 } inet-pton ] unit-test

[ "1.2.3.4" ]
[ B{ 1 2 3 4 } T{ inet4 } inet-ntop ] unit-test

[ "255.255.255.255" ]
[ B{ 255 255 255 255 } T{ inet4 } inet-ntop ] unit-test

[ B{ 255 255 255 255 } ]
[ "255.255.255.255" T{ inet4 } inet-pton ] unit-test

[ B{ 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 } ]
[ "1:2:3:4:5:6:7:8" T{ inet6 } inet-pton ] unit-test

[ "1:2:3:4:5:6:7:8" ]
[ B{ 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 } T{ inet6 } inet-ntop ] unit-test

[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } ]
[ "::" T{ inet6 } inet-pton ] unit-test

[ "0:0:0:0:0:0:0:0" ]
[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } T{ inet6 } inet-ntop ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 } ]
[ "1::" T{ inet6 } inet-pton ] unit-test

[ B{ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 } ]
[ "::1" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 2 } ]
[ "1::2" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 0 0 0 0 0 0 0 0 0 0 2 0 3 } ]
[ "1::2:3" T{ inet6 } inet-pton ] unit-test

[ B{ 0 1 0 2 0 0 0 0 0 0 0 0 0 3 0 4 } ]
[ "1:2::3:4" T{ inet6 } inet-pton ] unit-test

[ "1:2:0:0:0:0:3:4" ]
[ B{ 0 1 0 2 0 0 0 0 0 0 0 0 0 3 0 4 } T{ inet6 } inet-ntop ] unit-test

