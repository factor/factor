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

USING: alien.syntax alien.varargs ;
LIBRARY: sqlite
FUNCTION-ALIAS: format-sql char* sqlite3_mprintf ( c-string format, ... c-string name, int count, double value )
FUNCTION-ALIAS: format-buffer char* sqlite3_snprintf ( int size, char* output, c-string format, ... c-string name, int count, double value )
FUNCTION-ALIAS: append-sql void sqlite3_str_appendf ( sqlite3_str* builder, c-string format, ... c-string name, int count, double value )

:: owned-text ( pointer -- text )
    [ pointer utf8 alien>string ] [ pointer sqlite3_free ] finally ;

{ "'O''Brien':42:1.25" } [ "%Q:%d:%.2f" "O'Brien" 42 1.25 format-sql owned-text ] unit-test

:: truncated-buffer ( size -- text pointer? )
    32 <byte-array> :> output
    size output "%Q:%d:%.2f" "O'Brien" 42 1.25 format-buffer :> result
    output utf8 alien>string result alien? ;
{ "'O''Brien':42:1.25" t } [ 32 truncated-buffer ] unit-test
{ "'O''Bri" t } [ 8 truncated-buffer ] unit-test
{ "" t } [ 0 truncated-buffer ] unit-test

{ "prefix:'O''Brien':42:1.25" } [
    f sqlite3_str_new
    dup "prefix:" sqlite3_str_appendf
    dup "%Q:%d:%.2f" "O'Brien" 42 1.25 append-sql
    sqlite3_str_finish owned-text
] unit-test

! Owned results and caller-provided buffers must remain raw pointers.
{ t } [
    { sqlite3_mprintf sqlite3_vmprintf sqlite3_snprintf sqlite3_vsnprintf sqlite3_str_finish }
    [ def>> first pointer: char = ] all?
] unit-test
{ t } [
    { sqlite3_snprintf sqlite3_vsnprintf }
    [ def>> fourth second pointer: char = ] all?
] unit-test
{ t } [
    { sqlite3_vmprintf sqlite3_vsnprintf sqlite3_str_vappendf }
    [ def>> fourth last va_list = ] all?
] unit-test
