! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel time tools.test calendar ;

IN: time.tests

[ "%H:%M:%S" strftime ] must-infer 

: testtime ( -- timestamp )
    2008 10 9 12 3 15 instant <timestamp> ;

[ t ] [ "12:03:15" testtime "%H:%M:%S" strftime = ] unit-test
[ t ] [ "12:03:15" testtime "%X" strftime = ] unit-test

[ t ] [ "10/09/2008" testtime "%m/%d/%Y" strftime = ] unit-test
[ t ] [ "10/09/2008" testtime "%x" strftime = ] unit-test

[ t ] [ "Thu" testtime "%a" strftime = ] unit-test
[ t ] [ "Thursday" testtime "%A" strftime = ] unit-test

[ t ] [ "Oct" testtime "%b" strftime = ] unit-test
[ t ] [ "October" testtime "%B" strftime = ] unit-test

