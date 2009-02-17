! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math kernel sets generic
ui.baseline-alignment ui.baseline-alignment.private ;
IN: ui.baseline-alignment.tests

! Test baseline calculations
[ 10 ] [ 0 10 0 combine-metrics + ] unit-test
[ 15 ] [ 0 10 5 combine-metrics + ] unit-test
[ 30 ] [ 30 0 0 combine-metrics + ] unit-test
[ 35 ] [ 10 0 30 combine-metrics + ] unit-test
[ 20 ] [ 5 10 10 combine-metrics + ] unit-test
[ 20 ] [ 20 10 0 combine-metrics + ] unit-test
[ 55 ] [ 20 10 40 combine-metrics + ] unit-test

[ t ] [ \ baseline \ cap-height [ order ] bi@ set= ] unit-test 