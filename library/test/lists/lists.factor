IN: temporary
USING: kernel lists sequences test ;

[ 3 ] [ [ 3 ]         peek ] unit-test
[ 3 ] [ [ 1 2 3 ]     peek ] unit-test
[ 3 ] [ [[ 1 [[ 2 [[ 3 4 ]] ]] ]] peek ] unit-test

[ 0 ] [ [ ]       length ] unit-test
[ 3 ] [ [ 1 2 3 ] length ] unit-test

[ t ] [ f         list? ] unit-test
[ f ] [ t         list? ] unit-test
[ t ] [ [ 1 2 ]   list? ] unit-test
[ f ] [ [[ 1 2 ]] list? ] unit-test

[ [ ]         ] [ 0   >list ] unit-test
[ [ 0 1 2 3 ] ] [ 4   >list ] unit-test
