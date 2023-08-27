! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel multisets prettyprint tools.test ;
IN: multisets.tests

{ multiset{ } } [
    <multiset>
        100 over multiset-emplace
        100 over multiset-emplace
        100 over multiset-erase
] unit-test

{ t } [
    <multiset>
        100 over multiset-emplace
        100 over multiset-emplace
    multiset{ 100 100 } =
] unit-test

{ t } [ multiset{ } multiset-empty? ] unit-test
{ f } [ multiset{ 100 100 } multiset-empty? ] unit-test

{ t } [ multiset{ 100 100 } 100 multiset-in? ] unit-test
{ f } [ multiset{ 100 100 } 200 multiset-in? ] unit-test

{ 2 } [ multiset{ 100 100 } 100 multiset-count ] unit-test
{ 0 } [ multiset{ 100 100 } 200 multiset-count ] unit-test

{ { 100 100 } } [ multiset{ 100 100 } multiset-members ] unit-test


{ } [ multiset{ 100 100 } [ . ] multiset-each ] unit-test

{ 0 } [ multiset{ } size>> ] unit-test
{ 0 } [ multiset{ 100 100 } [ multiset-clear ] [ size>> ] bi ] unit-test
{ 2 } [ multiset{ 100 100 } size>> ] unit-test
