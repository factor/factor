! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.unix tools.test ;
IN: io.standard-paths.unix.tests

[ f ] [ "" find-path ] unit-test
[ "/bin/ls" ] [ "ls" find-path ] unit-test
[ "/sbin/ifconfig" ] [ "ifconfig" find-path ] unit-test
