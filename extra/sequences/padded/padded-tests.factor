! Copyright (C) 2020 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: arrays sequences.padded tools.test ;

{ { 1 2 3 } } [ { 1 2 3 } 3 f <padded-head> >array ] unit-test
{ { f f 1 2 3 } } [ { 1 2 3 } 5 f <padded-head> >array ] unit-test

{ { 1 2 3 } } [ { 1 2 3 } 3 f <padded-tail> >array ] unit-test
{ { 1 2 3 f f } } [ { 1 2 3 } 5 f <padded-tail> >array ] unit-test
