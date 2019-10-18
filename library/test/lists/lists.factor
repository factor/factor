IN: scratchpad
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: test
USE: strings

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 | 4 ] ] [ [ 1 2 3 ] 4     append ] unit-test

[ f         ] [ 3 [ ]     contains? ] unit-test
[ f         ] [ 3 [ 1 2 ] contains? ] unit-test
[ t ] [ 1 [ 1 2 ] contains? >boolean ] unit-test
[ t ] [ 2 [ 1 2 ] contains? >boolean ] unit-test

[ [ 3 ]     ] [ [ 3 ]         last* ] unit-test
[ [ 3 ]     ] [ [ 1 2 3 ]     last* ] unit-test
[ [ 3 | 4 ] ] [ [ 1 2 3 | 4 ] last* ] unit-test

[ 3 ] [ [ 3 ]         last ] unit-test
[ 3 ] [ [ 1 2 3 ]     last ] unit-test
[ 3 ] [ [ 1 2 3 | 4 ] last ] unit-test

[ 0 ] [ [ ]       length ] unit-test
[ 3 ] [ [ 1 2 3 ] length ] unit-test

[ t ] [ f         list? ] unit-test
[ f ] [ t         list? ] unit-test
[ t ] [ [ 1 2 ]   list? ] unit-test
[ f ] [ [ 1 | 2 ] list? ] unit-test

[ [ ]       ] [ 1 [ ]           remove ] unit-test
[ [ ]       ] [ 1 [ 1 ]         remove ] unit-test
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ] remove ] unit-test

[ [ ]       ] [ [ ]       reverse ] unit-test
[ [ 1 ]     ] [ [ 1 ]     reverse ] unit-test
[ [ 3 2 1 ] ] [ [ 1 2 3 ] reverse ] unit-test

[ [ 1 2 3 ] ] [ 1 [ 2 3 ]   unique ] unit-test
[ [ 1 2 3 ] ] [ 1 [ 1 2 3 ] unique ] unit-test
[ [ 1 2 3 ] ] [ 2 [ 1 2 3 ] unique ] unit-test

[ f ] [ 3 [ ]             tree-contains?     ] unit-test
[ f ] [ 3 [ 1 [ 3 ] 2 ]   tree-contains? not ] unit-test
[ f ] [ 1 [ [ [ 1 ] ] 2 ] tree-contains? not ] unit-test
[ f ] [ 2 [ 1 2 ]         tree-contains? not ] unit-test
[ f ] [ 3 [ 1 2 | 3 ]     tree-contains? not ] unit-test

[ [ ]         ] [ 0   count ] unit-test
[ [ ]         ] [ -10 count ] unit-test
[ [ 0 1 2 3 ] ] [ 4   count ] unit-test
