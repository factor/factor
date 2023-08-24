! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: hash-sets.numbers kernel sets tools.test ;

{ t } [ 1.5 NHS{ 3/2 } in? ] unit-test

{ NHS{ 3/2 } } [
    1.5 NHS{ 3/2 } [ adjoin ] keep
] unit-test

{ t } [
    NHS{ } clone 1.5 over adjoin
    3/2 swap in?
] unit-test

{ { 1.5 } } [ NHS{ 1.5 } members ] unit-test
