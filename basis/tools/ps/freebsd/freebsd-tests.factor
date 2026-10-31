USING: assocs kernel system tools.ps tools.ps.freebsd tools.test
unix.ffi ;
IN: tools.ps.freebsd.tests

{ { 42 "/usr/local/bin/factor -run=tools.test" } } [
    "   42 /usr/local/bin/factor -run=tools.test" parse-ps-line
] unit-test

os freebsd? [
    { t } [ getpid ps key? ] unit-test
] when

{ { 7 "[kernel]" } } [
    "\t7\t[kernel]" parse-ps-line
] unit-test

{ { 123 "program first  second" } } [
    "123   program first  second" parse-ps-line
] unit-test
