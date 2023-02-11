! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs hashtables.sequences kernel literals sequences
tools.test ;

{ 1000 } [ 0 4 "asdf" <slice> SH{ { "asdf" 1000 } } at ] unit-test

{ 1001 } [
    1001 0 4 "asdf" <slice> SH{ { "asdf" 1000 } }
    [ set-at ] [ at ] 2bi
] unit-test

{ 1001 } [
    SH{ } clone 1001 0 4 "asdf" <slice> pick set-at
    "asdf" of
] unit-test

{ { { "asdf" 1000 } } } [ SH{ { "asdf" 1000 } } >alist ] unit-test
