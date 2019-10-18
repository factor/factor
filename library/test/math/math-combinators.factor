IN: temporary
USE: kernel
USE: math
USE: test
USE: namespaces

[ ] [ 5 [ ] times ] unit-test
[ ] [ 0 [ ] times ] unit-test
[ ] [ -1 [ ] times ] unit-test

[ ] [ 5 [ ] repeat ] unit-test
[ [ 0 1 2 3 4 ] ] [ [ 5 [ dup , ] repeat ] [ ] make ] unit-test
[ [ ] ] [ [ -1 [ dup , ] repeat ] [ ] make ] unit-test
