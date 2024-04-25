USING: literals sequences sequences.repeating tools.test ;

{ { 1 } } [ { 1 2 3 } 1 cycle ] unit-test
{ { 1 2 3 1 2 } } [ { 1 2 3 } 5 cycle ] unit-test
{ { 1 2 3 1 2 3 1 2 3 } } [ { 1 2 3 } 9 cycle ] unit-test

{ $[ { 1 2 } minimum ] } [ { 1 2 3 } 2 <cycles> minimum ] unit-test
{ $[ { 1 2 3 1 2 } minimum ] } [ { 1 2 3 } 5 <cycles> minimum ] unit-test
{ $[ { 1 2 3 1 2 3 1 2 3 } minimum ] } [ { 1 2 3 } 9 <cycles> minimum ] unit-test
{ $[ { 1 2 } maximum ] } [ { 1 2 3 } 2 <cycles> maximum ] unit-test
{ $[ { 1 2 3 1 2 } maximum ] } [ { 1 2 3 } 5 <cycles> maximum ] unit-test
{ $[ { 1 2 3 1 2 3 1 2 3 } maximum ] } [ { 1 2 3 } 9 <cycles> maximum ] unit-test

{ { } } [ { 1 2 3 } 0 repeat-elements ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } 1 repeat-elements ] unit-test
{ { 1 1 2 2 3 3 } } [ { 1 2 3 } 2 repeat-elements ] unit-test
{ { 1 1 1 2 2 2 3 3 3 } } [ { 1 2 3 } 3 repeat-elements ] unit-test
{ { 1 1 1 1 2 2 2 2 3 3 3 3 } } [ { 1 2 3 } 4 repeat-elements ] unit-test

{ $[ { 1 1 1 2 2 2 3 3 3 } minimum ] } [ { 1 2 3 } 3 <element-repeats> minimum ] unit-test
{ $[ { 1 1 1 1 2 2 2 2 3 3 3 3 } minimum ] } [ { 1 2 3 } 4 <element-repeats> minimum ] unit-test
{ $[ { 1 1 1 2 2 2 3 3 3 } maximum ] } [ { 1 2 3 } 3 <element-repeats> maximum ] unit-test
{ $[ { 1 1 1 1 2 2 2 2 3 3 3 3 } maximum ] } [ { 1 2 3 } 4 <element-repeats> maximum ] unit-test

{ { } } [ { 1 2 3 } 0 repeat ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } 1 repeat ] unit-test
{ { 1 2 3 1 2 3 } } [ { 1 2 3 } 2 repeat ] unit-test
{ { 1 2 3 1 2 3 1 2 3 } } [ { 1 2 3 } 3 repeat ] unit-test
{ { 1 2 3 1 2 3 1 2 3 1 2 3 } } [ { 1 2 3 } 4 repeat ] unit-test

