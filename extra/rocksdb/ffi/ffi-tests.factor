! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel multiline rocksdb.ffi tools.test ;
IN: rocksdb.ffi.tests

![[
{ } [
    rocksdb_restore_options_create
    rocksdb_restore_options_destroy
] unit-test

! Added recently, not in homebrew yet
{ 123 } [
    rocksdb_writeoptions_create
    [ 123 rocksdb_writeoptions_set_sync ]
    [ rocksdb_writeoptions_get_sync ]
    [ rocksdb_writeoptions_destroy ] tri
] unit-test
]]
