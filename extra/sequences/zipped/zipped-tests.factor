! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: arrays tools.test ;
IN: sequences.zipped

{ { { 1 4 } { 2 5 } { 3 6 } } }
[ { 1 2 3 } { 4 5 6 } <zipped> >array ] unit-test
