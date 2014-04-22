! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: environment io.standard-paths io.standard-paths.unix
sequences tools.test ;
IN: io.standard-paths.unix.tests

{ f } [ "" find-in-path ] unit-test
{ t } [
    "ls" find-in-path { "/bin/ls" "/usr/bin/ls" } member?
] unit-test

{ t } [
    ! On Ubuntu, the path is ``/sbin/ifconfig``, however
    ! find-in-path uses the PATH environment variable which does
    ! not include this directory, so we do.
    "/sbin:" "PATH" os-env append "PATH" [
        "ifconfig" find-in-path
        { "/sbin/ifconfig" "/usr/bin/ifconfig" } member?
    ] with-os-env
] unit-test
