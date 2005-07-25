IN: temporary
USING: kernel lists sequences test ;

[ 1 ] [ 0 [ 1 2 ] nth ] unit-test
[ 2 ] [ 1 [ 1 2 ] nth ] unit-test

[ [ ]           ] [ [ ]   [ ]       append ] unit-test
[ [ 1 ]         ] [ [ 1 ] [ ]       append ] unit-test
[ [ 2 ]         ] [ [ ] [ 2 ]       append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] [ 4 ] append ] unit-test
[ [ 1 2 3 4 ]   ] [ [ 1 2 3 ] { 4 } append ] unit-test

[ [ 3 ]     ] [ [ 3 ]         last ] unit-test
[ [ 3 ]     ] [ [ 1 2 3 ]     last ] unit-test
[ [[ 3 4 ]] ] [ [[ 1 [[ 2 [[ 3 4 ]] ]] ]] last ] unit-test

[ 3 ] [ [ 3 ]         peek ] unit-test
[ 3 ] [ [ 1 2 3 ]     peek ] unit-test
[ 3 ] [ [[ 1 [[ 2 [[ 3 4 ]] ]] ]] peek ] unit-test

[ 0 ] [ [ ]       length ] unit-test
[ 3 ] [ [ 1 2 3 ] length ] unit-test

[ t ] [ f         list? ] unit-test
[ f ] [ t         list? ] unit-test
[ t ] [ [ 1 2 ]   list? ] unit-test
[ f ] [ [[ 1 2 ]] list? ] unit-test

[ [ ]       ] [ 1 [ ]           remove ] unit-test
[ [ ]       ] [ 1 [ 1 ]         remove ] unit-test
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ] remove ] unit-test

[ [ ]       ] [ [ ]       reverse ] unit-test
[ [ 1 ]     ] [ [ 1 ]     reverse ] unit-test
[ [ 3 2 1 ] ] [ [ 1 2 3 ] reverse ] unit-test

[ [ 1 2 3 ] ] [ 1 [ 2 3 ]   unique ] unit-test
[ [ 1 2 3 ] ] [ 1 [ 1 2 3 ] unique ] unit-test
[ [ 1 2 3 ] ] [ 2 [ 1 2 3 ] unique ] unit-test

[ [ ]         ] [ 0   >list ] unit-test
[ [ 0 1 2 3 ] ] [ 4   >list ] unit-test

[ f ] [ 0 f head ] unit-test
[ f ] [ 0 [ 1 ] head ] unit-test
[ [ 1 2 3 ] ] [ 3 [ 1 2 3 4 ] head ] unit-test
[ f ] [ 3 [ 1 2 3 ] tail ] unit-test
[ [ 3 ] ] [ 2 [ 1 2 3 ] tail ] unit-test

[ [ 1 3 ] ] [ [ 2 ] [ 1 2 3 ] seq-diff ] unit-test

[ t ] [ [ 1 2 3 ] [ 1 2 3 4 5 ] contained? ] unit-test
[ f ] [ [ 1 2 3 6 ] [ 1 2 3 4 5 ] contained? ] unit-test

[ t ] [ [ 1 2 3 ] [ 1 2 3 ] sequence= ] unit-test
[ t ] [ [ 1 2 3 ] { 1 2 3 } sequence= ] unit-test
[ t ] [ { 1 2 3 } [ 1 2 3 ] sequence= ] unit-test
[ f ] [ [ ] [ 1 2 3 ] sequence= ] unit-test
