! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays sequences sequences.windowed tools.test ;

{ { { 1 } { 1 2 } { 1 2 3 } { 2 3 4 } { 3 4 5 } { 4 5 6 } } }
[ { 1 2 3 4 5 6 } 3 <windowed-sequence> [ >array ] map ] unit-test

{ { { 1 } { 1 2 } { 1 2 3 } { 2 3 4 } { 3 4 5 } { 4 5 6 } } }
[ { 1 2 3 4 5 6 } 3 [ >array ] rolling-map ] unit-test

{ 6 }
[ { 1 2 3 4 5 6 } 3 <windowed-sequence> length ] unit-test

{ { 1 1 1 2 3 4 } }
[ { 1 2 3 4 5 6 } 3 <windowed-sequence> [ infimum ] map ] unit-test
