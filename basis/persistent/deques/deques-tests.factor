! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test persistent.deques kernel math ;
IN: persistent.deques.tests

[ 3 2 1 t ]
[ { 1 2 3 } sequence>deque 3 [ pop-right ] times deque-empty? ] unit-test

[ 1 2 3 t ]
[ { 1 2 3 } sequence>deque 3 [ pop-left ] times deque-empty? ] unit-test

[ 1 3 2 t ]
[ { 1 2 3 } sequence>deque pop-left 2 [ pop-right ] times deque-empty? ]
unit-test

[ { 2 3 4 5 6 1 } ]
[ { 1 2 3 4 5 6 } sequence>deque pop-left swap push-right deque>sequence ]
unit-test

[ 1 t ] [ <deque> 1 push-left pop-right deque-empty? ] unit-test
[ 1 t ] [ <deque> 1 push-left pop-left deque-empty? ] unit-test
[ 1 t ] [ <deque> 1 push-right pop-left deque-empty? ] unit-test
[ 1 t ] [ <deque> 1 push-right pop-right deque-empty? ] unit-test

[ 1 f ]
[ <deque> 1 push-left 2 push-left pop-right deque-empty? ] unit-test

[ 1 f ]
[ <deque> 1 push-right 2 push-right pop-left deque-empty? ] unit-test

[ 2 f ]
[ <deque> 1 push-right 2 push-right pop-right deque-empty? ] unit-test

[ 2 f ]
[ <deque> 1 push-left 2 push-left pop-left deque-empty? ] unit-test
