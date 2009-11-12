! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar.holidays.us kernel sequences tools.test ;
IN: calendar.holidays.us.tests

[ 10 ] [ 2009 us-federal holidays length ] unit-test
[ ] [ 2009 canada holidays drop ] unit-test
