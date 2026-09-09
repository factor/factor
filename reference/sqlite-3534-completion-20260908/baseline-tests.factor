USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax arrays byte-arrays continuations db.sqlite.ffi
io.encodings.string io.encodings.utf16 io.encodings.utf8 kernel
libc locals math sequences tools.test words ;
IN: sqlite.release.core.tests

{ "3.53.4" } [ sqlite3_libversion ] unit-test

: check ( code -- ) 0 assert= ;
: memory-db ( -- db )
    ":memory:" { void* } [ sqlite3_open check ] with-out-parameters ;
: prepare ( db sql -- stmt )
    -1 { void* void* } [ sqlite3_prepare_v2 check ] with-out-parameters drop ;
: exec-sql ( db sql -- ) f f f sqlite3_exec check ;

:: expanded-result ( -- pointer? text )
    memory-db :> db
    [
        db "SELECT ?1" prepare :> stmt
        [
            stmt 1 123 sqlite3_bind_int check
            stmt sqlite3_expanded_sql :> result
            result alien?
            result alien? [
                [ result utf8 alien>string ] [ result sqlite3_free ] finally
            ] [ result ] if
        ] [ stmt sqlite3_finalize check ] finally
    ] [ db sqlite3_close check ] finally ;

{ t "SELECT 123" } [ expanded-result ] unit-test

:: serialized-result ( -- pointer? binary-header? )
    memory-db :> db
    [
        db "CREATE TABLE data(v); INSERT INTO data VALUES(42)" exec-sql
        db "main" { longlong } [ 0 sqlite3_serialize ] with-out-parameters :> size :> result
        result alien?
        result alien? [
            [ result 16 memory>byte-array B{ 83 81 76 105 116 101 32 102 111 114 109 97 116 32 51 0 } = size 4096 >= and ]
            [ result sqlite3_free ] finally
        ] [ f ] if
    ] [ db sqlite3_close check ] finally ;

{ t t } [ serialized-result ] unit-test

{ t } [ \ sqlite3_prepare16 def>> fourth second pointer: void = ] unit-test
{ t } [ \ sqlite3_deserialize def>> fourth third pointer: uchar = ] unit-test
