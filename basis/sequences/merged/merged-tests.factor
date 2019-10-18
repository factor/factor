USING: sequences sequences.merged tools.test ;

{ 0 { 1 2 } } [ 0 T{ merged f { { 1 2 } { 3 4 } } } virtual@ ] unit-test
{ 0 { 3 4 } } [ 1 T{ merged f { { 1 2 } { 3 4 } } } virtual@ ] unit-test
{ 1 { 1 2 } } [ 2 T{ merged f { { 1 2 } { 3 4 } } } virtual@ ] unit-test
{ 4 } [ 3 { { 1 2 3 4 } } <merged> nth ] unit-test
[ 4 { { 1 2 3 4 } } <merged> nth ] must-fail

{ 1 } [ 0 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test
{ 4 } [ 1 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test
{ 2 } [ 2 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test
{ 5 } [ 3 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test
{ 3 } [ 4 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test
{ 6 } [ 5 { 1 2 3 } { 4 5 6 } <2merged> nth ] unit-test

{ 4 } [ 4 { 1 2 } { 3 4 } { 5 6 } 3merge nth ] unit-test

{ "" } [ "abcdefg" "" 2merge ] unit-test
{ "a1b2" } [ "abc" "12" <2merged> "" like ] unit-test
