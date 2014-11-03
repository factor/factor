! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
combinators destructors forestdb.ffi fry io.pathnames kernel
libc namespaces sequences tools.test ;
IN: forestdb.lib

CONSTANT: forestdb-test-path "resource:forestdbs/first.fdb"

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
