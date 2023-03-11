! Copyright (C) 2008 Marc Fauconneau.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test suffix-arrays kernel namespaces sequences ;

! built from [ all-words 10 head [ name>> ] map ]
{ } [
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
    } >suffix-array "suffix-array" set
] unit-test

{ t }
[ "suffix-array" get "" swap query empty? not ] unit-test

{ { } }
[ SA{ } "something" swap query ] unit-test

{ { "unit-test" "(unit-test)" } }
[ "suffix-array" get "unit-test" swap query ] unit-test

{ t }
[ "suffix-array" get "something else" swap query empty? ] unit-test

{ { "rofl" } } [ SA{ "rofl" } "r" swap query ] unit-test
{ { "rofl" } } [ SA{ "rofl" } "o" swap query ] unit-test
{ { "rofl" } } [ SA{ "rofl" } "f" swap query ] unit-test
{ { "rofl" } } [ SA{ "rofl" } "l" swap query ] unit-test
{ { } } [ SA{ "rofl" } "t" swap query ] unit-test
