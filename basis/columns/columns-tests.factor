USING: arrays columns kernel math namespaces sequences
tools.test ;

! Columns
{ { 1 2 3 } { 4 5 6 } { 7 8 9 } } [ clone ] map "seq" set

{ { 1 4 7 } } [ "seq" get 0 <column> >array ] unit-test
[ "seq" get 1 <column> [ sq ] map! ] must-not-fail
{ { 4 25 64 } } [ "seq" get 1 <column> >array ] unit-test

{ { { 1 3 } { 2 4 } } } [ { { 1 2 } { 3 4 } } <flipped> [ >array ] map ] unit-test
