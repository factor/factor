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
       "key123" "val123" fdb-set-kv
       "key123" fdb-get-kv
    ] with-forestdb
] unit-test

{ "val12345" } [
    forestdb-test-path [
       "key123" "val12345" fdb-set-kv
       "key123" fdb-get-kv
    ] with-forestdb
] unit-test


{ f } [
    ! Filename is only valid inside with-forestdb
    forestdb-test-path [
        get-current-db-info filename>> alien>native-string empty?
    ] with-forestdb
] unit-test

{ 6 9 9 } [
    forestdb-test-path [
       "key123" "meta blah" "some body" fdb-doc-create
        [ keylen>> ] [ metalen>> ] [ bodylen>> ] tri
    ] with-forestdb
] unit-test

{ 7 8 15 } [
    forestdb-test-path [
       "key1234" "meta blah" "some body" fdb-doc-create
        dup "new meta" "some other body" fdb-doc-update
        [ keylen>> ] [ metalen>> ] [ bodylen>> ] tri
    ] with-forestdb
] unit-test
