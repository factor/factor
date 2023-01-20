! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: regexp.combinators tools.test regexp kernel sequences ;
IN: regexp.combinators.tests

: strings ( -- regexp )
    { "foo" "bar" "baz" } <any-of> ;

{ t t t } [ "foo" "bar" "baz" [ strings matches? ] tri@ ] unit-test
{ f f f } [ "food" "ibar" "ba" [ strings matches? ] tri@ ] unit-test

: conj ( -- regexp )
    { R/ .*a/ R/ b.*/ } <and> ;

{ t } [ "bljhasflsda" conj matches? ] unit-test
{ f } [ "bsdfdfs" conj matches? ] unit-test
{ f } [ "fsfa" conj matches? ] unit-test

{ f } [ "bljhasflsda" conj <not> matches? ] unit-test
{ t } [ "bsdfdfs" conj <not> matches? ] unit-test
{ t } [ "fsfa" conj <not> matches? ] unit-test

{ f f } [ "" "hi" [ <nothing> matches? ] bi@ ] unit-test
{ t t } [ "" "hi" [ <nothing> <not> matches? ] bi@ ] unit-test

{ { t t t f } } [ { "" "a" "aaaaa" "aab" } [ "a" <literal> <zero-or-more> matches? ] map ] unit-test
{ { f t t f } } [ { "" "a" "aaaaa" "aab" } [ "a" <literal> <one-or-more> matches? ] map ] unit-test
{ { t t f f } } [ { "" "a" "aaaaa" "aab" } [ "a" <literal> <option> matches? ] map ] unit-test
