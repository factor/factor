! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations gdbm io.directories
io.files.temp kernel sequences sets system tools.test ;
IN: gdbm.tests

: db-path ( -- filename ) cpu name>> "-test.db" append temp-file ;

: CLEANUP ( -- ) db-path ?delete-file ;

: test.db ( -- gdbm ) <gdbm> db-path >>name ;

: with-test.db ( quot -- ) test.db swap with-gdbm ; inline

CLEANUP

[
    test.db reader >>role [ ] with-gdbm
] [ gdbm-file-open-error = ] must-fail-with

{ f } [ [ "foo" gdbm-exists? ] with-test.db ] unit-test

{ } [ [ "foo" 41 gdbm-insert ] with-test.db ] unit-test

[
    db-path [ "foo" 42 gdbm-insert ] with-gdbm-writer
] [ gdbm-cannot-replace = ] must-fail-with

{ }
[
    [
        "foo" 42 gdbm-replace
        "bar" 43 gdbm-replace
        "baz" 44 gdbm-replace
    ] with-test.db
] unit-test

{ 42 t } [ db-path [ "foo" gdbm-fetch* ] with-gdbm-reader ] unit-test

{ f f } [ [ "unknown" gdbm-fetch* ] with-test.db ] unit-test

{ t }
[
    V{ } [ [ 2array append ] each-gdbm-record ] with-test.db
    V{ "foo" "bar" "baz" 42 43 44 } set=

] unit-test

{ f }
[
    test.db newdb >>role [ "foo" gdbm-exists? ] with-gdbm
] unit-test

CLEANUP
