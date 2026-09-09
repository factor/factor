USING: accessors alien alien.c-types alien.strings byte-arrays
combinators continuations db.sqlite.ffi io.encodings.utf8 kernel
locals sequences tools.test words ;
IN: db.sqlite.ffi.tests

! These declarations are zero-tail call shapes of variadic C functions.
{ { 1 3 2 1 2 1 2 2 } } [
    { sqlite3_mprintf sqlite3_snprintf sqlite3_str_appendf sqlite3_config
      sqlite3_db_config sqlite3_test_control sqlite3_log sqlite3_vtab_config }
    [ def>> 4 swap nth ] map
] unit-test

! The FFI must retain ownership-bearing pointers, not silently copy strings.
: owned-result? ( result -- ? )
    dup alien? [ sqlite3_free t ] [ drop f ] if ;

{ t } [ "literal" sqlite3_mprintf owned-result? ] unit-test
{ t } [
    f sqlite3_str_new dup "literal" sqlite3_str_appendf
    sqlite3_str_finish owned-result?
] unit-test

:: literal-buffer ( -- pointer? text )
    32 <byte-array> :> output
    32 output "literal" sqlite3_snprintf alien?
    output utf8 alien>string ;
{ t "literal" } [ literal-buffer ] unit-test
