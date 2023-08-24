! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: interpolate io.streams.string namespaces tools.test locals ;

{ "A B" } [ "A" "B" "${1} ${0}" interpolate>string ] unit-test
{ "B A" } [ "A" "B" "${0} ${1}" interpolate>string ] unit-test
{ "C A" } [ "A" "B" "C" "${0} ${2}" interpolate>string ] unit-test
{ "C B A" } [ "A" "B" "C" "${} ${1} ${2}" interpolate>string ] unit-test

{ "Hello, Jane." } [
    "Jane" "name" set
    "Hello, ${name}." interpolate>string
] unit-test

{ "Mr. John" } [
    "John" "name" set
    "Mr." "${0} ${name}" interpolate>string
] unit-test

{ "Hello, Mr. Anderson" } [
    "Mr." "Anderson"
    "Hello, ${} ${}" interpolate>string
] unit-test

{ "Mixing named and stack variables... stacks are cool!" } [
    "cool!" "what" set
    "named" "stack"
    "Mixing ${} and ${} variables... ${0}s are ${what}"
    interpolate>string
] unit-test

{ "Sup Dawg, we heard you liked rims, so we put rims on your rims so you can roll while you roll." } [
    "Dawg" "name" set
    "rims" "noun" set
    "roll" "verb" set
    "Sup ${name}, we heard you liked ${noun}, so we put ${noun} on your ${noun} so you can ${verb} while you ${verb}." interpolate>string
] unit-test

{ "Oops, I accidentally the whole economy..." } [
    [let
        "economy" :> noun
        "accidentally" [ [I Oops, I ${0} the whole ${noun}...I] ] with-string-writer
    ]
] unit-test
