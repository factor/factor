! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.string io.encodings.utf8 kernel rocksdb.lib
tools.test multiline ;
IN: rocksdb.lib.tests

: with-my-rocksdb ( quot -- )
    [ "/Users/erg/my-rocks.db" ] dip with-rocksdb ; inline

![[
{ "this is a" } [
    [
        [ make-write-options-sync "a" "this is a" rocksdb-put* drop ]
        [ make-read-options "a" rocksdb-get* drop utf8 decode ] bi 
    ] with-my-rocksdb
] unit-test
]]
