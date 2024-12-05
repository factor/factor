! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: arrays sequences sequences.snipped tools.test ;

{ { 0 1 2 5 6 } } [ 3 5 7 <iota> <snipped> >array ] unit-test
{ { 0 1 2 } } [ 3 10 7 <iota> <snipped> >array ] unit-test
{ { 5 6 } } [ -1 5 7 <iota> <snipped> >array ] unit-test
{ { } } [ -1 10 7 <iota> <snipped> >array ] unit-test

{ { 1 2 3 } } [ -1 { 1 2 3 } <removed> >array ] unit-test
{ { 2 3 } } [ 0 { 1 2 3 } <removed> >array ] unit-test
{ { 1 3 } } [ 1 { 1 2 3 } <removed> >array ] unit-test
{ { 1 2 } } [ 2 { 1 2 3 } <removed> >array ] unit-test
{ { 1 2 3 } } [ 3 { 1 2 3 } <removed> >array ] unit-test
