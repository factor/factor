! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: arrays sequences sequences.shifted tools.test ;

{ { 1 2 3 7 } } [ 4 <iota> -1 7 <shifted> >array ] unit-test
{ { 7 0 1 2 } } [ 4 <iota> 1 7 <shifted> >array ] unit-test
{ { 0 1 2 3 } } [ 4 <iota> 0 f <shifted> >array ] unit-test
{ { f f f f } } [ 4 <iota> 4 f <shifted> >array ] unit-test
{ { f f f f } } [ 4 <iota> -4 f <shifted> >array ] unit-test
