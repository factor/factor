! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs countries kernel sets system tools.test
unicode.flags unicode.flags.images ;
IN: unicode.flags.images.tests

{ } [ valid-flag-biassoc drop ] unit-test

! Windows doesn't seem to have these flags yet (!)
{ { } } [
    os macosx? [
        valid-flag-names alpha-2 keys diff
        [ dup unicode>flag ] { } map>assoc
    ] [
        { }
    ] if
] unit-test
