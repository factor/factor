! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations gdbm gdbm.ffi io.directories
io.files.temp kernel sequences sets tools.test ;
IN: gdbm.tests

: db-path ( -- filename ) "test.db" temp-file ;

: CLEANUP ( -- ) [ db-path delete-file ] ignore-errors ;

: test.db ( -- gdbm ) <gdbm> db-path >>name ;

: with-test.db ( quot -- ) test.db swap with-gdbm ; inline


CLEANUP


[
    test.db reader >>role [ ] with-gdbm
] [ gdbm-file-open-error = ] must-fail-with

[ f ] [ [ "foo" gdbm-exists ] with-test.db ] unit-test

[ ] [ [ "foo" 41 gdbm-insert ] with-test.db ] unit-test

[
    [ "foo" 42 gdbm-insert ] with-test.db
] [ gdbm-cannot-replace = ] must-fail-with

[ ]
[
    [
        "foo" 42 gdbm-replace
        "bar" 43 gdbm-replace
        "baz" 44 gdbm-replace
    ] with-test.db
] unit-test

[ 42 t ] [ [ "foo" gdbm-fetch* ] with-test.db ] unit-test

[ f f ] [ [ "unknown" gdbm-fetch* ] with-test.db ] unit-test

[
    [
        300 gdbm-set-cache-size 300 gdbm-set-cache-size
    ] with-test.db
] [ gdbm-option-already-set = ] must-fail-with

[ t ]
[
    V{ }
    [
        gdbm-first-key
        [ gdbm-next-key* ] [ [ swap push ] 2keep ] do while drop
    ] with-test.db
    V{ "foo" "bar" "baz" } set=

] unit-test

[ f ]
[
    test.db newdb >>role [ "foo" gdbm-exists ] with-gdbm
] unit-test


CLEANUP
