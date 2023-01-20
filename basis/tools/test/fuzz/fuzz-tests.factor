! Copyright (C) 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel macros math namespaces sequences
source-files.errors tools.test tools.test.fuzz
tools.test.fuzz.private tools.test.private ;
IN: tools.test.fuzz.tests

SYMBOL: generator-stack
: with-generator-stack ( seq quot -- )
    [ reverse V{ } like generator-stack ] dip with-variable ; inline
: generate-from-stack ( -- n )
    generator-stack get pop ;

6 fuzz-test-trials [

    [ { } ] [
        { -4 -2 0 2 4 6 } [
            [ generate-from-stack ] [ even? ] fuzz-test-failures
        ] with-generator-stack
    ] unit-test

    [ { { -1 } { 1 } { 5 } } ] [
        { -4 -1 1 2 5 6 } [
            [ generate-from-stack ] [ even? ] fuzz-test-failures
        ] with-generator-stack
    ] unit-test

    { -4 -2 0 2 4 6 } [
        [ generate-from-stack ] [ even? ] fuzz-test
    ] with-generator-stack

    {
        1
        T{ fuzz-test-failure
            { failures { { -1 } { 1 } { 5 } } }
            { predicate [ even? ] }
            { trials 6 }
        }
    } [
        [
            { -4 -2 0 2 4 6 } [
                [ generate-from-stack ] [ even? ] fuzz-test
            ] with-generator-stack
            { -4 -1 1 2 5 6 } [
                [ generate-from-stack ] [ even? ] fuzz-test
            ] with-generator-stack
        ] fake-unit-test
        [ length ] [ first error>> ] bi
    ] unit-test

] with-variable

notify-error-observers
