! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs hashtables.numbers kernel literals sequences
tools.test ;

{ 1000 } [ 3/2 NH{ { 1.5 1000 } } at ] unit-test

{ 1001 } [
    1001 1.5 NH{ { 3/2 1000 } }
    [ set-at ] [ at ] 2bi
] unit-test

{ 1001 } [
    NH{ } clone 1001 1.5 pick set-at
    3/2 of
] unit-test

{ { { 1.0 1000 } } } [ NH{ { 1.0 1000 } } >alist ] unit-test
