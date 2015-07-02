! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: code-arrays locals math tools.test ;
IN: code-arrays.tests

{ { 1 2 9 } } [ {{ 1 2 3 sq }} ] unit-test
{ { 1 2 { 9 } } } [ {{ 1 2 {{ 3 sq }} }} ] unit-test

{ H{ { 9 3 } { 4 1 } } } [ H{{ {{ 3 sq 3 }} {{ 2 sq 1 }} }} ] unit-test

:: local-code-arrays ( -- seq ) {{ 1 2 3 + }} ;

{ { 1 5 } } [ local-code-arrays ] unit-test
