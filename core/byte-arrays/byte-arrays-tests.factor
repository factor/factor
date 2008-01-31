IN: temporary
USING: tools.test byte-arrays ;

[ B{ 1 2 3 0 0 0 } ] [ 6 B{ 1 2 3 } resize-byte-array ] unit-test

[ B{ 1 2 } ] [ 2 B{ 1 2 3 4 5 6 7 8 9 } resize-byte-array ] unit-test

[ -10 B{ } resize-byte-array ] unit-test-fails
