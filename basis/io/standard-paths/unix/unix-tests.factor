! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: environment io.standard-paths io.standard-paths.unix
sequences tools.test ;

{ f } [ "" find-in-path ] unit-test
{ t } [
    "ls" find-in-path { "/bin/ls" "/usr/bin/ls" } member?
] unit-test

{ t } [
    "/sbin:" "PATH" os-env append "PATH" [
        "ps" find-in-path
        { "/bin/ps" "/sbin/ps" "/usr/bin/ps" } member?
    ] with-os-env
] unit-test

{ t } [
    "ls" find-in-standard-login-path 
    { "/bin/ls" "/usr/bin/ls" } member?
] unit-test
