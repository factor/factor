USING: accessors alien alien.c-types alien.data arrays classes.struct
combinators continuations db.sqlite.ffi db.sqlite.ffi.release-tests
kernel locals sequences tools.test words ;
IN: db.sqlite.ffi.release-tests.tests

! This suite requires the explicitly built library; missing symbols/options fail.
{ "3.53.4" } [ sqlite3_libversion ] unit-test
{ t } [
    { "ENABLE_SESSION" "ENABLE_PREUPDATE_HOOK" "ENABLE_FTS5"
      "ENABLE_CARRAY" "ENABLE_COLUMN_METADATA" "ENABLE_STMT_SCANSTATUS"
      "ENABLE_NORMALIZE" "ENABLE_SNAPSHOT" }
    [ sqlite3_compileoption_used 1 = ] all?
] unit-test

! These four checks are also run against the unmodified declarations.
{ t } [ "sqlite3session_create" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ t } [ "sqlite3_carray_bind_v2" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ t } [ "sqlite3_preupdate_hook" "db.sqlite.ffi" lookup-word >boolean ] unit-test
{ 48 } [ fts5_api heap-size ] unit-test

:: session-roundtrip ( -- total )
    optional_open :> source
    optional_open :> target
    [
        source "main" { void* } [ sqlite3session_create 0 assert= ] with-out-parameters :> session
        [
            session "t" sqlite3session_attach 0 assert=
            source "INSERT INTO t VALUES(7,11),(8,19); UPDATE t SET v=29 WHERE id=7" optional_exec 0 assert=
            session { int void* } [ sqlite3session_changeset 0 assert= ] with-out-parameters :> ( size data )
            [ target size data f optional_conflict f sqlite3changeset_apply 0 assert= ]
            [ data sqlite3_free ] finally
            target optional_sum
        ] [ session sqlite3session_delete ] finally
    ] [ source sqlite3_close 0 assert= target sqlite3_close 0 assert= ] finally ;
{ 48 } [ session-roundtrip ] unit-test

:: carray-query ( -- sum destructor-count )
    optional_open :> db
    [
        db "SELECT sum(value) FROM carray(?1)" optional_prepare :> statement
        [
            statement 1 optional_array 3 SQLITE_CARRAY_INT64 optional_destructor optional_destructor_context
            sqlite3_carray_bind_v2 0 assert=
            statement sqlite3_step SQLITE_ROW assert=
            statement 0 sqlite3_column_int64
        ] [ statement sqlite3_finalize 0 assert= ] finally
        optional_destructor_calls
    ] [ db sqlite3_close 0 assert= ] finally ;
{ 1000000042 1 } [ carray-query ] unit-test

:: preupdate-callback ( -- result )
    optional_open :> db
    [
        db "INSERT INTO t VALUES(7,11)" optional_exec 0 assert=
        optional_preupdate_reset
        [| context connection op schema table oldid newid |
            connection sqlite3_preupdate_count 2 assert=
            connection sqlite3_preupdate_depth 0 assert=
            connection sqlite3_preupdate_blobwrite -1 assert=
            connection 1 { void* } [ sqlite3_preupdate_old 0 assert= ] with-out-parameters sqlite3_value_int 11 assert=
            connection 1 { void* } [ sqlite3_preupdate_new 0 assert= ] with-out-parameters sqlite3_value_int 29 assert=
            context connection op schema table oldid newid optional_preupdate_record
        ] sqlite3_preupdate_callback [| callback |
            db callback optional_destructor_context sqlite3_preupdate_hook drop
            [ db "UPDATE t SET v=29 WHERE id=7" optional_exec 0 assert= ]
            [ db f f sqlite3_preupdate_hook drop ] finally
        ] with-callback
        optional_preupdate_result
    ] [ db sqlite3_close 0 assert= ] finally ;
{ 1 } [ preupdate-callback ] unit-test

:: tokenizer-v2 ( -- api-version tokenizer-version valid )
    optional_open :> db
    [
        db optional_fts5_api fts5_api memory>struct :> api
        api optional_fts5_tokenizer fts5_tokenizer_v2 memory>struct :> tokenizer
        api iVersion>> tokenizer iVersion>>
        api api xFindTokenizer_v2>> tokenizer tokenizer xCreate>> tokenizer xDelete>> tokenizer xTokenize>> optional_fts5_verify
    ] [ db sqlite3_close 0 assert= ] finally ;
{ 3 0 1 } [ tokenizer-v2 ] unit-test
{ t t } [
    fts5_api heap-size optional_fts5_api_size =
    fts5_tokenizer_v2 heap-size optional_fts5_tokenizer_size =
] unit-test
