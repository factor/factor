USING: arrays sequences tensors.tensor-slice tools.test ;
IN: tensors.tensor-slice.tests

{ { 9 7 5 } } [ -1 -6 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 7 } } [ -1 -5 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 7 } } [ -1 -4 -2 10 <iota> <step-slice> >array ] unit-test
{ { 9 } } [ -1 -3 -2 10 <iota> <step-slice> >array ] unit-test
{ { } } [ -4 10 -2 10 <iota> <step-slice> >array ] unit-test
{ { 6 8 } } [ -4 15 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 } } [ 1 4 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 } } [ 1 5 2 10 <iota> <step-slice> >array ] unit-test
{ { 1 3 5 } } [ 1 6 2 10 <iota> <step-slice> >array ] unit-test