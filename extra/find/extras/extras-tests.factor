! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: find.extras kernel math.order sequences strings
tools.test ;
IN: find.extras.tests

{ { "#" "" } } [ "#" lex>strings ] unit-test
{ { "#" "asdf" } } [ "#asdf" lex>strings ] unit-test
{ { "{" { "1" "2" "3" } "}" } } [ "{ 1 2 3 }" lex>strings ] unit-test
{ { "arr{" { "1" "2" "3" } "}" } } [ "arr{ 1 2 3 }" lex>strings ] unit-test
{ { "quot[" { "1" "2" "3" } "]" } } [ "quot[ 1 2 3 ]" lex>strings ] unit-test
{ { "par(" { "1" "2" "3" } ")" } } [ "par( 1 2 3 )" lex>strings ] unit-test
{ { "tic" "`" " 1 2 3 " "`" } } [ "tic` 1 2 3 `" lex>strings ] unit-test

{
    "lol"
    3
    T{ slice f 0 3 "lol" }
} [ "lol" 0 [ char: a char: z between? ] take-empty-from ] unit-test

{
    "lol"
    3
    T{ slice f 0 3 "lol" }
} [ "lol" 0 tag-from ] unit-test

! Test combinations of [=[
{ "[=[" 3 T{ slice f 0 3 "[=[" } } [
    "[=[" 0 {
        [
            { [ "[" head-from ] [ [ char: = = ] take-empty-from ] [ "[" head-from ] } find-quots
            dup [ slices-combine ] when
        ]
    } find-quots slices-combine
] unit-test

{ "[=" 0 f } [
    "[=" 0 {
        [
            { [ "[" head-from ] [ [ char: = = ] take-empty-from ] [ "[" head-from ] } find-quots
            dup [ slices-combine ] when
        ]
    } find-quots slices-combine
] unit-test

{ "[" 0 f } [
    "[" 0 {
        [
            { [ "[" head-from ] [ [ char: = = ] take-empty-from ] [ "[" head-from ] } find-quots
            dup [ slices-combine ] when
        ]
    } find-quots slices-combine
] unit-test

{ "" 0 f } [
    "" 0 {
        [
            { [ "[" head-from ] [ [ char: = = ] take-empty-from ] [ "[" head-from ] } find-quots
            dup [ slices-combine ] when
        ]
    } find-quots slices-combine
] unit-test


{ f 0 f } [
    f 0 {
        [
            { [ "[" head-from ] [ [ char: = = ] take-empty-from ] [ "[" head-from ] } find-quots
            dup [ slices-combine ] when
        ]
    } find-quots slices-combine
] unit-test

!
{ } [
    "foo\"asdf\"" lex-tokens drop
] unit-test

{ } [ " \"lol\" " lex-tokens drop ] unit-test
{ } [ " foo\"lol\" " lex-tokens drop ] unit-test

{ t } [ "[[lololol]]" 2 "]]" read-until-subseq >boolean 2nip nip ] unit-test
