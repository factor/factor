! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
combinators destructors forestdb.ffi fry io.files.temp
io.pathnames kernel libc namespaces sequences tools.test ;
IN: forestdb.lib

: forestdb-test-path ( -- path )
    "forestdb-test.fdb" temp-file ;

{ "val123" } [
    forestdb-test-path [
       "key123" "val123" fdb-set
       "key123" fdb-get
    ] with-forestdb
] unit-test

{ "val12345" } [
    forestdb-test-path [
       "key123" "val12345" fdb-set
       "key123" fdb-get
    ] with-forestdb
] unit-test
