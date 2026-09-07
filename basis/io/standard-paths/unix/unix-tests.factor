! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: environment io.directories io.encodings.utf8 io.files
io.files.info.unix io.files.links io.pathnames io.standard-paths
io.standard-paths.unix kernel sequences splitting tools.test ;
IN: io.standard-paths.unix.tests

: path-fixture ( -- )
    { "blocked" "directory" "valid" } [ make-directory ] each
    "not executable" "blocked/probe" utf8 set-file-contents
    "blocked/probe" 0o644 set-file-permissions
    "directory/probe" make-directory
    "#!/bin/sh\nexit 0\n" "valid/probe" utf8 set-file-contents
    "valid/probe" 0o755 set-file-permissions ;

{ t } [
    [
        path-fixture
        { "blocked" "directory" "valid" } [ absolute-path ] map ":" join
        "PATH" [ "probe" find-in-path "valid/probe" absolute-path = ] with-os-env
    ] with-test-directory
] unit-test

{ f } [
    [
        path-fixture
        "blocked:directory" "PATH" [ "probe" find-in-path ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        path-fixture "links" make-directory
        "valid/probe" absolute-path "links/probe" make-link
        "links:valid" "PATH" [ "probe" find-in-path "links/probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        path-fixture "links" make-directory
        "absent" "links/probe" make-link
        "links:valid" "PATH" [ "probe" find-in-path "valid/probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        "#!/bin/sh\nexit 0\n" "probe" utf8 set-file-contents
        "probe" 0o755 set-file-permissions
        "" "PATH" [ "probe" find-in-path "probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ f } [ f "PATH" [ "ls" find-in-path ] with-os-env ] unit-test

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
