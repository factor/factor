! Copyright (C) 2008 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: boxes hats kernel namespaces symbols tools.test ;
IN: hats.tests

SYMBOLS: lion giraffe elephant rabbit ;

! caps
[ rabbit ] [ rabbit <cap> out ] unit-test
[ rabbit ] [ f <cap> rabbit in out ] unit-test
[ rabbit ] [ rabbit <cap> take ] unit-test
[ f ] [ rabbit <cap> empty-hat out ] unit-test
[ rabbit f ] [ rabbit <cap> [ take ] keep out ] unit-test
[ rabbit t ] [ rabbit <cap> [ take ] keep empty-hat? ] unit-test
[ lion ] [ rabbit <cap> [ drop lion ] change-hat out ] unit-test

! bowlers
[ giraffe ] [ [ giraffe rabbit set rabbit <bowler> out ] with-scope ] unit-test

[ rabbit ]
[
    [
        lion rabbit set [
            rabbit rabbit set rabbit <bowler> out
        ] with-scope
    ] with-scope
] unit-test

[ rabbit ] [
    rabbit <bowler>
    [
        lion rabbit set [
            rabbit rabbit set out
        ] with-scope
    ] with-scope
] unit-test

[ elephant ] [
    rabbit <bowler>
    [
        elephant rabbit set [
            rabbit rabbit set
        ] with-scope
        out
    ] with-scope
] unit-test

[ rabbit ] [
    rabbit <bowler>
    [
        elephant in [
            rabbit in out
        ] with-scope
    ] with-scope
] unit-test

[ elephant ] [
    rabbit <bowler>
    [
        elephant in [
            rabbit in
        ] with-scope
        out
    ] with-scope
] unit-test

! Top Hats
[ lion ] [ lion rabbit set-global rabbit <top-hat> out ] unit-test
[ giraffe ] [ rabbit <top-hat> giraffe in out ] unit-test

! Tuple hats
TUPLE: foo bar ;
C: <foo> foo

: test-tuple ( -- tuple )
    rabbit <foo> ;

: test-slot-hat ( -- slot-hat )
    test-tuple 2 <slot-hat> ; ! hack!

[ rabbit ] [ test-slot-hat out ] unit-test
[ lion ] [ test-slot-hat lion in out ] unit-test

! Boxes as hats
[ rabbit ] [ <box> rabbit in out ] unit-test
[ <box> rabbit in lion in ] must-fail
[ <box> out ] must-fail
