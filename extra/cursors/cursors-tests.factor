! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cursors math tools.test make ;
IN: cursors.tests

[ 2 t ] [ { 2 3 } [ even? ] find ] unit-test
[ 3 t ] [ { 2 3 } [ odd? ] find ] unit-test
[ f f ] [ { 2 4 } [ odd? ] find ] unit-test

[ { 2 3 } ] [ { 1 2 } [ 1 + ] map ] unit-test
[ { 2 3 } ] [ { 1 2 } [ [ 1 + , ] each ] { 2 3 } make ] unit-test

[ t ] [ { } [ odd? ] all? ] unit-test
[ t ] [ { 1 3 5 } [ odd? ] all? ] unit-test
[ f ] [ { 1 3 5 6 } [ odd? ] all? ] unit-test

[ t ] [ { } [ odd? ] all? ] unit-test
[ t ] [ { 1 3 5 } [ odd? ] any? ] unit-test
[ f ] [ { 2 4 6 } [ odd? ] any? ] unit-test

[ { 1 3 5 } ] [ { 1 2 3 4 5 6 } [ odd? ] filter ] unit-test

[ { } ]
[ { 1 2 } { } [ + ] 2map ] unit-test

[ { 11 } ]
[ { 1 2 } { 10 } [ + ] 2map ] unit-test

[ { 11 22 } ]
[ { 1 2 } { 10 20 } [ + ] 2map ] unit-test

[ { } ]
[ { 1 2 } { } { } [ + + ] 3map ] unit-test

[ { 111 } ]
[ { 1 2 } { 10 } { 100 200 } [ + + ] 3map ] unit-test

[ { 111 222 } ]
[ { 1 2 } { 10 20 } { 100 200 } [ + + ] 3map ] unit-test
