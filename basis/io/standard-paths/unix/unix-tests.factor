! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.unix sequences
tools.test ;
IN: io.standard-paths.unix.tests

{ f } [ "" find-in-path ] unit-test
{ t } [
    "ls" find-in-path { "/bin/ls" "/usr/bin/ls" } member?
] unit-test
{ t } [
    "ifconfig" find-in-path
    { "/sbin/ifconfig" "/usr/bin/ifconfig" } member?
] unit-test
