IN: scratchpad
USE: arithmetic
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: test

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 | 4 ] ] [ [ 1 2 3 ] 4     append ] unit-test

[ [ ]         ] [ [ ]         clone-list ] unit-test
[ [ 1 2 | 3 ] ] [ [ 1 2 | 3 ] clone-list ] unit-test
[ [ 1 2 3 4 ] ] [ [ 1 2 3 4 ] clone-list ] unit-test

: clone-list-actually-clones? ( list1 list2 -- )
    >r clone-list ! we don't want to mutate literals
    dup clone-list r> nappend = not ;

[ t ] [ [ 1 2 ] [ 3 4 ] clone-list-actually-clones? ] unit-test

[ f         ] [ 3 [ ]     contains ] unit-test
[ f         ] [ 3 [ 1 2 ] contains ] unit-test
[ [ 1 2 ]   ] [ 1 [ 1 2 ] contains ] unit-test
[ [ 2 ]     ] [ 2 [ 1 2 ] contains ] unit-test

[ 1 ] [  -1 [ 1 2 ] nth ] unit-test
[ 1 ] [  0  [ 1 2 ] nth ] unit-test
[ 2 ] [  1  [ 1 2 ] nth ] unit-test

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

[ 2 ] [ 1 [ 1 2 3 ] next ] unit-test
[ 1 ] [ 3 [ 1 2 3 ] next ] unit-test
[ 1 ] [ 4 [ 1 2 3 ] next ] unit-test

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

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] subset ] unit-test

[ [ t f t f ] ] [ f 1 [ t 1 t 1 ] substitute ] unit-test

[ [ 0 1 2 4 5 6 7 8 9 ] ] [ 3 10 count remove-nth ] unit-test
[ [ 1 2 3 4 5 6 7 8 9 ] ] [ 0 10 count remove-nth ] unit-test
[ [ 0 1 2 3 4 5 6 7 8 ] ] [ 9 10 count remove-nth ] unit-test

[ [ 1 2 3 ] ] [ 2 1 [ 1 3 3 ] set-nth ] unit-test
[ [ 1 2 3 ] ] [ 1 0 [ 2 2 3 ] set-nth ] unit-test
[ [ 1 2 3 ] ] [ 3 2 [ 1 2 2 ] set-nth ] unit-test
