! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs countries kernel sets tools.test unicode.flags
unicode.flags.images ;
IN: unicode.flags.images.tests

{ } [ valid-flag-biassoc drop ] unit-test

{ { } } [
    valid-flag-names alpha-2 keys diff
    [ dup unicode>flag ] { } map>assoc
] unit-test
