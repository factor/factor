! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: interpolate io.streams.string namespaces tools.test locals ;
IN: interpolate.tests

[ "Hello, Jane." ] [
    "Jane" "name" set
    [ "Hello, ${name}." interpolate ] with-string-writer
] unit-test

[ "Sup Dawg, we heard you liked rims, so we put rims on your rims so you can roll while you roll." ] [
    "Dawg" "name" set
    "rims" "noun" set
    "roll" "verb" set
    [ "Sup ${name}, we heard you liked ${noun}, so we put ${noun} on your ${noun} so you can ${verb} while you ${verb}." interpolate ] with-string-writer
] unit-test

[ "Oops, I accidentally the whole economy..." ] [
    [let
        "economy" :> noun
        [ I[ Oops, I accidentally the whole ${noun}...]I ] with-string-writer
    ]
] unit-test
