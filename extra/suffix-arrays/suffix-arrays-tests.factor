! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test suffix-arrays kernel namespaces ;
IN: suffix-arrays.tests

! built from [ all-words 10 head [ name>> ] map ]
{
    "run-tests"
    "must-fail-with"
    "test-all"
    "short-effect"
    "failure"
    "test"
    "<failure>"
    "this-test"
    "(unit-test)"
    "unit-test"
} "strings" set

[ "strings" get >suffix-array "" swap query ] must-fail

[ { } >suffix-array "something" swap query ] must-fail

[ V{ "unit-test" "(unit-test)" } ]
[ "strings" get >suffix-array "unit-test" swap query ] unit-test

[ V{ } ] [ "strings" get >suffix-array "something else" swap query ] unit-test
