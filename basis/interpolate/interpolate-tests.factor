! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: interpolate io.streams.string namespaces tools.test locals ;
IN: interpolate.tests

{ "A B" } [ "A" "B" "${0} ${1}" interpolate ] unit-test
{ "B A" } [ "A" "B" "${1} ${0}" interpolate ] unit-test
{ "C A" } [ "A" "B" "C" "${2} ${0}" interpolate ] unit-test

{ "Hello, Jane." } [
    "Jane" "name" set
    "Hello, ${name}." interpolate
] unit-test

{ "Mr. John" } [
    "John" "name" set
    "Mr." "${0} ${name}" interpolate
] unit-test

{ "Sup Dawg, we heard you liked rims, so we put rims on your rims so you can roll while you roll." } [
    "Dawg" "name" set
    "rims" "noun" set
    "roll" "verb" set
    "Sup ${name}, we heard you liked ${noun}, so we put ${noun} on your ${noun} so you can ${verb} while you ${verb}." interpolate
] unit-test

{ "Oops, I accidentally the whole economy..." } [
    [let
        "economy" :> noun
        "accidentally" [ I[ Oops, I ${0} the whole ${noun}...]I ] with-string-writer
    ]
] unit-test
