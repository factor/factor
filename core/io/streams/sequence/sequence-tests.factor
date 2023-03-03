! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.streams.sequence io.streams.string kernel tools.test ;
IN: io.streams.sequence.tests

{
    "abc" 102
} [
    "abcfdef" <string-reader>
    "fd" swap sequence-read-until
] unit-test

{
    "" 100
} [
    "abcfdef" <string-reader>
    [ "fd" swap sequence-read-until 2drop ] keep "fd" swap sequence-read-until
] unit-test

{
    "e" 102
} [
    "abcfdef" <string-reader>
    [ "fd" swap sequence-read-until 2drop ] keep
    [ "fd" swap sequence-read-until 2drop ] keep
    "fd" swap sequence-read-until
] unit-test
