! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: strings tools.test ;
IN: math.transforms.bwt

{ "asdf" } [ "asdf" bwt ibwt >string ] unit-test
