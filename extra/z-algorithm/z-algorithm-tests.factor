! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test z-algorithm ;

{ 0 } [ "qwerty" "" lcp ] unit-test
{ 0 } [ "qwerty" "asdf" lcp ] unit-test
{ 3 } [ "qwerty" "qwe" lcp ] unit-test
{ 3 } [ "qwerty" "qwet" lcp ] unit-test

{ { } } [ "" z-values ] unit-test
{ { 1 } } [ "q" z-values ] unit-test
{ { 9 0 5 0 3 0 1 0 1 } } [ "abababaca" z-values ] unit-test
