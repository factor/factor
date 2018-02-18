USING: accessors arrays kernel sequences sequences.modified tools.test ;

{ { 2 4 6 } } [ { 1 2 3 } 2 scale ] unit-test
{ { 1 4 3 } } [ { 1 2 3 } 2 <scaled> 8 1 pick set-nth seq>> ] unit-test
{ { 2 8 6 } } [ { 1 2 3 } 2 <scaled> 8 1 pick set-nth >array ] unit-test

{ { 2 3 4 } } [ { 1 2 3 } 1 seq-offset ] unit-test
{ { 1 5 3 } } [ { 1 2 3 } 1 <offset> 6 1 pick set-nth seq>> ] unit-test
{ { 2 6 4 } } [ { 1 2 3 } 1 <offset> 6 1 pick set-nth >array ] unit-test

{ 4 } [ { { 1 2 } { 3 4 } } <summed> 0 swap nth ] unit-test
{ 6 } [ { { 1 2 } { 3 4 } } <summed> 1 swap nth ] unit-test
{ 2 } [ { { 1 2 } { 3 4 } } <summed> length ] unit-test
{ { 4 6 } } [ { { 1 2 } { 3 4 } } <summed> >array ] unit-test
