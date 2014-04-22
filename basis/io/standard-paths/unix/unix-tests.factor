! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.unix sequences
tools.test ;
IN: io.standard-paths.unix.tests

{ f } [ "" find-in-path ] unit-test
{ t } [
    "ls" find-in-path { "/bin/ls" "/usr/bin/ls" } member?
] unit-test

! On Ubuntu, the path is ``/sbin/ifconfig``, however
! find-in-path uses the PATH environment variable which does
! not include this directory. So we can just make sure it runs.
{ } [ "ifconfig" find-in-path drop ] unit-test
