USING: kernel math math.compare math.functions sequences
tools.test ;

{ -1 } [ -1 5 absmin ] unit-test
{ -1 } [ -1 -5 absmin ] unit-test

{ -5 } [ 1 -5 absmax ] unit-test
{ 5 } [ 1 5 absmax ] unit-test

{ 0 } [ -1 -3 posmax ] unit-test
{ 1 } [ 1 -3 posmax ] unit-test
{ 3 } [ -1 3 posmax ] unit-test

{ 0 } [ 1 3 negmin ] unit-test
{ -3 } [ 1 -3 negmin ] unit-test
{ -1 } [ -1 3 negmin ] unit-test

{ 1 } [ 1 2 [ ] min-by ] unit-test
{ 1 } [ 2 1 [ ] min-by ] unit-test
{ 42.0 } [ 42.0 1/0. [ ] min-by ] unit-test
{ 42.0 } [ 1/0. 42.0 [ ] min-by ] unit-test
{ 2 } [ 1 2 [ ] max-by ] unit-test
{ 2 } [ 2 1 [ ] max-by ] unit-test
{ 1/0. } [ 42.0 1/0. [ ] max-by ] unit-test
{ 1/0. } [ 1/0. 42.0 [ ] max-by ] unit-test
{ "12345" } [ "123" "12345" [ length ] max-by ] unit-test
{ "123" } [ "123" "12345" [ length ] min-by ] unit-test
