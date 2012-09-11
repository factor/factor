! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: strings tools.test ;
IN: sequences.rotated

{ "fasd" } [ "asdf" -1 <rotated> >string ] unit-test
{ "sdfa" } [ "asdf" 1 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" 0 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" 4 <rotated> >string ] unit-test
{ "asdf" } [ "asdf" -4 <rotated> >string ] unit-test
