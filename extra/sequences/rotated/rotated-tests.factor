! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: sequences.rotated strings tools.test ;

{ "fasd" } [ "asdf" -1 <rotated> >string ] unit-test
{ "sdfa" } [ "asdf" 1 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" 0 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" 4 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" -4 <rotated> >string ] unit-test
