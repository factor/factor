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

:: binary-roundtrip ( -- value )
    memory-db :> source
    source "CREATE TABLE data(v); INSERT INTO data VALUES(8675309)" exec-sql
    source "main" { longlong } [ 0 sqlite3_serialize ] with-out-parameters :> size :> bytes
    source sqlite3_close check
    memory-db :> target
    [
        ! SQLite owns the allocation after this call, including failure paths.
        target "main" bytes size size SQLITE_DESERIALIZE_FREEONCLOSE sqlite3_deserialize check
        target "SELECT v FROM data" prepare :> stmt
        [ stmt sqlite3_step SQLITE_ROW assert= stmt 0 sqlite3_column_int ]
        [ stmt sqlite3_finalize check ] finally
    ] [ target sqlite3_close check ] finally ;

{ 8675309 } [ binary-roundtrip ] unit-test

:: prepare-utf16 ( -- text )
    memory-db :> db
    [
        "SELECT 'λ雪'" utf16n encode :> sql
        db sql sql length { void* void* } [ sqlite3_prepare16 check ] with-out-parameters drop :> stmt
        [ stmt sqlite3_step SQLITE_ROW assert= stmt 0 sqlite3_column_text ]
        [ stmt sqlite3_finalize check ] finally
    ] [ db sqlite3_close check ] finally ;

{ "λ雪" } [ prepare-utf16 ] unit-test
{ t } [ \ sqlite3_prepare16 def>> fourth second pointer: void = ] unit-test
{ t } [ \ sqlite3_deserialize def>> fourth third pointer: uchar = ] unit-test

:: native-filename ( -- pointer? database journal wal )
    "sample.db" "sample.db-journal" "sample.db-wal" 0 f sqlite3_create_filename :> name
    [
        name alien?
        name sqlite3_filename_database utf8 alien>string
        name sqlite3_filename_journal utf8 alien>string
        name sqlite3_filename_wal utf8 alien>string
    ] [ name sqlite3_free_filename ] finally ;

{ t "sample.db" "sample.db-journal" "sample.db-wal" } [ native-filename ] unit-test

:: builder-truncate ( -- text )
    f sqlite3_str_new :> builder
    [
        builder "abcdef" sqlite3_str_appendall
        builder 3 sqlite3_str_truncate
        builder "XYZ" sqlite3_str_appendall
        builder sqlite3_str_value
    ] [ builder sqlite3_str_free ] finally ;

{ "abcXYZ" } [ builder-truncate ] unit-test
