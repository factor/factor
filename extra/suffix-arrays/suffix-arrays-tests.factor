! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test suffix-arrays kernel namespaces sequences ;
IN: suffix-arrays.tests

! built from [ all-words 10 head [ name>> ] map ]
[ ] [
     SA{
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
    } "suffix-array" set
] unit-test

[ "suffix-array" get "" swap query ] must-fail

[ SA{ } "something" swap query ] must-fail

[ V{ "unit-test" "(unit-test)" } ]
[ "suffix-array" get "unit-test" swap query ] unit-test

[ t ]
[ "suffix-array" get "something else" swap query empty? ] unit-test
