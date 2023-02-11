! Copyright (C) 2013 Loryn Jenkins.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.combinators tools.test ;

{ 0 } [ -3 [ drop 0 ] when-negative ] unit-test
{ -2 } [ -3 [ 1 + ] when-negative ] unit-test
{ 2 } [ 2 [ 0 ] when-negative ] unit-test

{ 0 } [ 3 [ drop 0 ] when-positive ] unit-test
{ 4 } [ 3 [ 1 + ] when-positive ] unit-test
{ -2 } [ -2 [ 0 ] when-positive ] unit-test
