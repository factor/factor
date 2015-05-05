! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: kernel tools.test ;
IN: math.transforms.bwt

{ "asdf" } [ "asdf" bwt ibwt ] unit-test

{ t } [ "hello" [ bwt nip ] [ bwt* ] bi = ] unit-test
