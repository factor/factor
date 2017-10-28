USING: continuations debugger io io.errors io.streams.string
kernel math multiline namespaces sequences tools.test
tools.test.private ;
IN: tools.test.tests

{ 1 } [
    [
        [ "OOPS" ] must-fail
    ] fake-unit-test length
] unit-test

: create-test-failure ( -- error )
    [ "hello" throw ] [
        f "path" 25 error-continuation get test-failure boa
    ] recover ;

! Just verifies that the presented output contains a callstack.
{ t } [
    create-test-failure [ error. ] with-string-writer
    "OBJ-CURRENT-THREAD" swap subseq?
] unit-test

UNIT-TEST: [ 1 1 + ] { 2 }

STDOUT-UNIT-TEST: [ "hello" write ] "hello"
STDERR-UNIT-TEST: [ "hello" ewrite ] "hello"

![[
<UNIT-TEST-FAILED
    UNIT-TEST-CODE: [ 1 1 + ]
    GOT-STACK: { 2 }
    EXPECTED-STACK: { 3 }
    EXPECTED-STDOUT: "hello world"
UNIT-TEST-FAILED>
]]
