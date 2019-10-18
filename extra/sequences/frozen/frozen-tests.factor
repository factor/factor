USING: arrays kernel sequences sequences.frozen
sequences.private tools.test ;

{ { 1 2 3 } } [ { 1 2 3 } <frozen> >array ] unit-test

[ 1 1 { 1 2 3 } <frozen> set-nth ] [ immutable? ] must-fail-with

{ "abc" } [ "abc" <frozen> dup like ] unit-test
