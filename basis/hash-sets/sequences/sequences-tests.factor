! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: hash-sets.sequences kernel literals sequences sets
tools.test ;

{ t } [ 0 4 "asdf" <slice> SHS{ "asdf" } in? ] unit-test

{ SHS{ "asdf" } } [
    0 4 "asdf" <slice> SHS{ "asdf" } [ adjoin ] keep
] unit-test

{ t } [
    SHS{ } clone 0 4 "asdf" <slice> over adjoin
    "asdf" swap in?
] unit-test

{ { "asdf" } } [ SHS{ "asdf" } members ] unit-test
