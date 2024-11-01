! Copyright (C) 2005 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! An interface to the sqlite database. Tested against sqlite v3.1.3.
! Not all functions have been wrapped.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: db.sqlite.ffi

C-LIBRARY: sqlite cdecl {
    { windows "sqlite3.dll" }
    { macos "libsqlite3.dylib" }
    { unix "libsqlite3.so" }
}

! Return values from sqlite functions
CONSTANT: SQLITE_OK           0  ! Successful result
CONSTANT: SQLITE_ERROR        1  ! SQL error or missing database
CONSTANT: SQLITE_INTERNAL     2  ! An internal logic error in SQLite
CONSTANT: SQLITE_PERM         3  ! Access permission denied
CONSTANT: SQLITE_ABORT        4  ! Callback routine requested an abort
CONSTANT: SQLITE_BUSY         5  ! The database file is locked
CONSTANT: SQLITE_LOCKED       6  ! A table in the database is locked
CONSTANT: SQLITE_NOMEM        7  ! A malloc() failed
CONSTANT: SQLITE_READONLY     8  ! Attempt to write a readonly database
CONSTANT: SQLITE_INTERRUPT    9  ! Operation terminated by sqlite_interrupt()
CONSTANT: SQLITE_IOERR       10  ! Some kind of disk I/O error occurred
CONSTANT: SQLITE_CORRUPT     11  ! The database disk image is malformed
CONSTANT: SQLITE_NOTFOUND    12  ! (Internal Only) Table or record not found
CONSTANT: SQLITE_FULL        13  ! Insertion failed because database is full
CONSTANT: SQLITE_CANTOPEN    14  ! Unable to open the database file
CONSTANT: SQLITE_PROTOCOL    15  ! Database lock protocol error
CONSTANT: SQLITE_EMPTY       16  ! (Internal Only) Database table is empty
CONSTANT: SQLITE_SCHEMA      17  ! The database schema changed
CONSTANT: SQLITE_TOOBIG      18  ! Too much data for one row of a table
CONSTANT: SQLITE_CONSTRAINT  19  ! Abort due to contraint violation
CONSTANT: SQLITE_MISMATCH    20  ! Data type mismatch
CONSTANT: SQLITE_MISUSE      21  ! Library used incorrectly
CONSTANT: SQLITE_NOLFS       22  ! Uses OS features not supported on host
CONSTANT: SQLITE_AUTH        23  ! Authorization denied
CONSTANT: SQLITE_FORMAT      24  ! Auxiliary database format error
CONSTANT: SQLITE_RANGE       25  ! 2nd parameter to sqlite3_bind out of range
CONSTANT: SQLITE_NOTADB      26  ! File opened that is not a database file
CONSTANT: SQLITE_NOTICE      27  ! Notifications from sqlite3_log()
CONSTANT: SQLITE_WARNING     28  ! Warnings from sqlite3_log()

CONSTANT: sqlite-error-messages {
    "Successful result"
    "SQL error or missing database"
    "An internal logic error in SQLite"
    "Access permission denied"
    "Callback routine requested an abort"
    "The database file is locked"
    "A table in the database is locked"
    "A malloc() failed"
    "Attempt to write a readonly database"
    "Operation terminated by sqlite_interrupt()"
    "Some kind of disk I/O error occurred"
    "The database disk image is malformed"
    "(Internal Only) Table or record not found"
    "Insertion failed because database is full"
    "Unable to open the database file"
    "Database lock protocol error"
    "(Internal Only) Database table is empty"
    "The database schema changed"
    "Too much data for one row of a table"
    "Abort due to contraint violation"
    "Data type mismatch"
    "Library used incorrectly"
    "Uses OS features not supported on host"
    "Authorization denied"
    "Auxiliary database format error"
    "2nd parameter to sqlite3_bind out of range"
    "File opened that is not a database file"
    "Notifications from sqlite3_log()"
    "Warnings from sqlite3_log()"
}

! Return values from sqlite3_step
CONSTANT: SQLITE_ROW         100
CONSTANT: SQLITE_DONE        101

! Return values from the sqlite3_column_type function
CONSTANT: SQLITE_INTEGER     1
CONSTANT: SQLITE_FLOAT       2
CONSTANT: SQLITE_TEXT        3
CONSTANT: SQLITE_BLOB        4
CONSTANT: SQLITE_NULL        5

! Values for the 'destructor' parameter of the 'bind' routines.
: SQLITE_STATIC ( -- ptr ) 0 <alien> ; inline
: SQLITE_TRANSIENT ( -- ptr ) -1 <alien> ; inline

CONSTANT: SQLITE_OPEN_READONLY         0x00000001
CONSTANT: SQLITE_OPEN_READWRITE        0x00000002
CONSTANT: SQLITE_OPEN_CREATE           0x00000004
CONSTANT: SQLITE_OPEN_DELETEONCLOSE    0x00000008
CONSTANT: SQLITE_OPEN_EXCLUSIVE        0x00000010
CONSTANT: SQLITE_OPEN_MAIN_DB          0x00000100
CONSTANT: SQLITE_OPEN_TEMP_DB          0x00000200
CONSTANT: SQLITE_OPEN_TRANSIENT_DB     0x00000400
CONSTANT: SQLITE_OPEN_MAIN_JOURNAL     0x00000800
CONSTANT: SQLITE_OPEN_TEMP_JOURNAL     0x00001000
CONSTANT: SQLITE_OPEN_SUBJOURNAL       0x00002000
CONSTANT: SQLITE_OPEN_MASTER_JOURNAL   0x00004000

CONSTANT: SQLITE_IOCAP_ATOMIC                 0x00000001
CONSTANT: SQLITE_IOCAP_ATOMIC512              0x00000002
CONSTANT: SQLITE_IOCAP_ATOMIC1K               0x00000004
CONSTANT: SQLITE_IOCAP_ATOMIC2K               0x00000008
CONSTANT: SQLITE_IOCAP_ATOMIC4K               0x00000010
CONSTANT: SQLITE_IOCAP_ATOMIC8K               0x00000020
CONSTANT: SQLITE_IOCAP_ATOMIC16K              0x00000040
CONSTANT: SQLITE_IOCAP_ATOMIC32K              0x00000080
CONSTANT: SQLITE_IOCAP_ATOMIC64K              0x00000100
CONSTANT: SQLITE_IOCAP_SAFE_APPEND            0x00000200
CONSTANT: SQLITE_IOCAP_SEQUENTIAL             0x00000400
CONSTANT: SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN  0x00000800
CONSTANT: SQLITE_IOCAP_POWERSAFE_OVERWRITE    0x00001000
CONSTANT: SQLITE_IOCAP_IMMUTABLE              0x00002000
CONSTANT: SQLITE_IOCAP_BATCH_ATOMIC           0x00004000

CONSTANT: SQLITE_LOCK_NONE          0
CONSTANT: SQLITE_LOCK_SHARED        1
CONSTANT: SQLITE_LOCK_RESERVED      2
CONSTANT: SQLITE_LOCK_PENDING       3
CONSTANT: SQLITE_LOCK_EXCLUSIVE     4

CONSTANT: SQLITE_SYNC_NORMAL        0x00002
CONSTANT: SQLITE_SYNC_FULL          0x00003
CONSTANT: SQLITE_SYNC_DATAONLY      0x00010

LIBRARY: sqlite

FUNCTION: c-string sqlite3_libversion ( )

FUNCTION: c-string sqlite3_sourceid ( )

FUNCTION: int sqlite3_libversion_number ( )

FUNCTION: int sqlite3_compileoption_used ( c-string zOptName )

FUNCTION: c-string sqlite3_compileoption_get ( int N )

FUNCTION: int sqlite3_threadsafe ( )

C-TYPE: sqlite3
TYPEDEF: longlong sqlite_int64
TYPEDEF: ulonglong sqlite_uint64
TYPEDEF: longlong sqlite3_int64
TYPEDEF: ulonglong sqlite3_uint64
FUNCTION: int sqlite3_close ( sqlite3* dummy )

FUNCTION: int sqlite3_close_v2 ( sqlite3* dummy )

TYPEDEF: void* sqlite3_callback
FUNCTION: int sqlite3_exec ( sqlite3* dummy, c-string sql, void* callback, void* dummy, char** errmsg )

C-TYPE: sqlite3_file
STRUCT: sqlite3_io_methods
  { iVersion int }
  { xClose void* }
  { xRead void* }
  { xWrite void* }
  { xTruncate void* }
  { xSync void* }
  { xFileSize void* }
  { xLock void* }
  { xUnlock void* }
  { xCheckReservedLock void* }
  { xFileControl void* }
  { xSectorSize void* }
  { xDeviceCharacteristics void* }
  { xShmMap void* }
  { xShmLock void* }
  { xShmBarrier void* }
  { xShmUnmap void* }
  { xFetch void* }
  { xUnfetch void* } ;

STRUCT: sqlite3_file
  { pMethods sqlite3_io_methods* } ;

C-TYPE: sqlite3_io_methods
C-TYPE: sqlite3_mutex
C-TYPE: sqlite3_api_routines
C-TYPE: sqlite3_vfs
TYPEDEF: void* sqlite3_syscall_ptr
STRUCT: sqlite3_vfs
  { iVersion int }
  { szOsFile int }
  { mxPathname int }
  { pNext sqlite3_vfs* }
  { zName c-string }
  { pAppData void* }
  { xOpen void* }
  { xDelete void* }
  { xAccess void* }
  { xFullPathname void* }
  { xDlOpen void* }
  { xDlError void* }
  { xDlSym void* }
  { xDlClose void* }
  { xRandomness void* }
  { xSleep void* }
  { xCurrentTime void* }
  { xGetLastError void* }
  { xCurrentTimeInt64 void* }
  { xSetSystemCall void* }
  { xGetSystemCall void* }
  { xNextSystemCall void* } ;

FUNCTION: int sqlite3_initialize ( )

FUNCTION: int sqlite3_shutdown ( )

FUNCTION: int sqlite3_os_init ( )

FUNCTION: int sqlite3_os_end ( )

FUNCTION: int sqlite3_config ( int dummy )

FUNCTION: int sqlite3_db_config ( sqlite3* dummy, int op )

C-TYPE: sqlite3_mem_methods
STRUCT: sqlite3_mem_methods
  { xMalloc void* }
  { xFree void* }
  { xRealloc void* }
  { xSize void* }
  { xRoundup void* }
  { xInit void* }
  { xShutdown void* }
  { pAppData void* } ;

FUNCTION: int sqlite3_extended_result_codes ( sqlite3* dummy, int onoff )

FUNCTION: longlong sqlite3_last_insert_rowid ( sqlite3* dummy )

FUNCTION: void sqlite3_set_last_insert_rowid ( sqlite3* dummy, sqlite3_int64 dummy )

FUNCTION: int sqlite3_changes ( sqlite3* dummy )

FUNCTION: int sqlite3_total_changes ( sqlite3* dummy )

FUNCTION: void sqlite3_interrupt ( sqlite3* dummy )

FUNCTION: int sqlite3_complete ( c-string sql )

FUNCTION: int sqlite3_complete16 ( void* sql )

FUNCTION: int sqlite3_busy_handler ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_busy_timeout ( sqlite3* dummy, int ms )

FUNCTION: int sqlite3_get_table ( sqlite3* db, c-string zSql, char*** pazResult, int* pnRow, int* pnColumn, char** pzErrmsg )

FUNCTION: void sqlite3_free_table ( char** result )

FUNCTION: c-string sqlite3_mprintf ( c-string dummy )

! FUNCTION: c-string sqlite3_vmprintf ( c-string dummy, va_list dummy )

FUNCTION: c-string sqlite3_snprintf ( int dummy, c-string dummy, c-string dummy )

! FUNCTION: c-string sqlite3_vsnprintf ( int dummy, c-string dummy, c-string dummy, va_list dummy )

FUNCTION: void* sqlite3_malloc ( int dummy )

FUNCTION: void* sqlite3_malloc64 ( sqlite3_uint64 dummy )

FUNCTION: void* sqlite3_realloc ( void* dummy, int dummy )

FUNCTION: void* sqlite3_realloc64 ( void* dummy, sqlite3_uint64 dummy )

FUNCTION: void sqlite3_free ( void* dummy )

FUNCTION: ulonglong sqlite3_msize ( void* dummy )

FUNCTION: longlong sqlite3_memory_used ( )

FUNCTION: longlong sqlite3_memory_highwater ( int resetFlag )

FUNCTION: void sqlite3_randomness ( int N, void* P )

FUNCTION: int sqlite3_set_authorizer ( sqlite3* dummy, void* xAuth, void* pUserData )

FUNCTION: void* sqlite3_trace ( sqlite3* dummy, void* xTrace, void* dummy )

FUNCTION: void* sqlite3_profile ( sqlite3* dummy, void* xProfile, void* dummy )

FUNCTION: int sqlite3_trace_v2 ( sqlite3* dummy, uint uMask, void* xCallback, void* pCtx )

FUNCTION: void sqlite3_progress_handler ( sqlite3* dummy, int dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_open ( c-string filename, sqlite3** ppDb )

FUNCTION: int sqlite3_open16 ( void* filename, sqlite3** ppDb )

FUNCTION: int sqlite3_open_v2 ( c-string filename, sqlite3** ppDb, int flags, c-string zVfs )

FUNCTION: c-string sqlite3_uri_parameter ( c-string zFilename, c-string zParam )

FUNCTION: int sqlite3_uri_boolean ( c-string zFile, c-string zParam, int bDefault )

FUNCTION: longlong sqlite3_uri_int64 ( c-string dummy, c-string dummy, sqlite3_int64 dummy )

FUNCTION: int sqlite3_errcode ( sqlite3* db )

FUNCTION: int sqlite3_extended_errcode ( sqlite3* db )

FUNCTION: c-string sqlite3_errmsg ( sqlite3* dummy )

FUNCTION: void* sqlite3_errmsg16 ( sqlite3* dummy )

FUNCTION: c-string sqlite3_errstr ( int dummy )

C-TYPE: sqlite3_stmt
FUNCTION: int sqlite3_limit ( sqlite3* dummy, int id, int newVal )

FUNCTION: int sqlite3_prepare ( sqlite3* db, c-string zSql, int nByte, sqlite3_stmt** ppStmt, char** pzTail )

FUNCTION: int sqlite3_prepare_v2 ( sqlite3* db, c-string zSql, int nByte, sqlite3_stmt** ppStmt, char** pzTail )

FUNCTION: int sqlite3_prepare_v3 ( sqlite3* db, c-string  zSql, int nByte, uint prepFlags, sqlite3_stmt** ppStmt, char** pzTail )

FUNCTION: int sqlite3_prepare16 ( sqlite3* db, c-string zSql, int nByte, sqlite3_stmt** ppStmt, void** pzTail )

FUNCTION: int sqlite3_prepare16_v2 ( sqlite3* db, void* zSql, int nByte, sqlite3_stmt** ppStmt, void** pzTail )

FUNCTION: int sqlite3_prepare16_v3 ( sqlite3* db, void* zSql, int nByte, uint prepFlags, sqlite3_stmt** ppStmt, void** pzTail )

FUNCTION: c-string sqlite3_sql ( sqlite3_stmt* pStmt )

FUNCTION: c-string sqlite3_expanded_sql ( sqlite3_stmt* pStmt )

FUNCTION: c-string sqlite3_normalized_sql ( sqlite3_stmt* pStmt )

FUNCTION: int sqlite3_stmt_readonly ( sqlite3_stmt* pStmt )

FUNCTION: int sqlite3_stmt_isexplain ( sqlite3_stmt* pStmt )

FUNCTION: int sqlite3_stmt_busy ( sqlite3_stmt* dummy )

C-TYPE: sqlite3_value
C-TYPE: sqlite3_context
FUNCTION: int sqlite3_bind_blob ( sqlite3_stmt* dummy, int dummy, void* dummy, int n, void* dummy )

FUNCTION: int sqlite3_bind_blob64 ( sqlite3_stmt* dummy, int dummy, void* dummy, sqlite3_uint64 dummy, void* dummy )

FUNCTION: int sqlite3_bind_double ( sqlite3_stmt* dummy, int dummy, double dummy )

FUNCTION: int sqlite3_bind_int ( sqlite3_stmt* dummy, int dummy, int dummy )

FUNCTION: int sqlite3_bind_int64 ( sqlite3_stmt* dummy, int dummy, sqlite3_int64 dummy )

FUNCTION: int sqlite3_bind_null ( sqlite3_stmt* dummy, int dummy )

FUNCTION: int sqlite3_bind_text ( sqlite3_stmt* dummy, int dummy, char* dummy, int dummy, void* dummy )

FUNCTION: int sqlite3_bind_text16 ( sqlite3_stmt* dummy, int dummy, void* dummy, int dummy, void* dummy )

FUNCTION: int sqlite3_bind_text64 ( sqlite3_stmt* dummy, int dummy, char* dummy, sqlite3_uint64 dummy, void* dummy, uchar encoding )

FUNCTION: int sqlite3_bind_value ( sqlite3_stmt* dummy, int dummy, sqlite3_value* dummy )

FUNCTION: int sqlite3_bind_pointer ( sqlite3_stmt* dummy, int dummy, void* dummy, char* dummy, void* dummy )

FUNCTION: int sqlite3_bind_zeroblob ( sqlite3_stmt* dummy, int dummy, int n )

FUNCTION: int sqlite3_bind_zeroblob64 ( sqlite3_stmt* dummy, int dummy, sqlite3_uint64 dummy )

FUNCTION: int sqlite3_bind_parameter_count ( sqlite3_stmt* dummy )

FUNCTION: c-string sqlite3_bind_parameter_name ( sqlite3_stmt* dummy, int dummy )

FUNCTION: int sqlite3_bind_parameter_index ( sqlite3_stmt* dummy, c-string zName )

FUNCTION: int sqlite3_clear_bindings ( sqlite3_stmt* dummy )

FUNCTION: int sqlite3_column_count ( sqlite3_stmt* pStmt )

FUNCTION: c-string sqlite3_column_name ( sqlite3_stmt* dummy, int N )

FUNCTION: void* sqlite3_column_name16 ( sqlite3_stmt* dummy, int N )

FUNCTION: c-string sqlite3_column_database_name ( sqlite3_stmt* dummy, int dummy )

FUNCTION: void* sqlite3_column_database_name16 ( sqlite3_stmt* dummy, int dummy )

FUNCTION: c-string sqlite3_column_table_name ( sqlite3_stmt* dummy, int dummy )

FUNCTION: void* sqlite3_column_table_name16 ( sqlite3_stmt* dummy, int dummy )

FUNCTION: c-string sqlite3_column_origin_name ( sqlite3_stmt* dummy, int dummy )

FUNCTION: void* sqlite3_column_origin_name16 ( sqlite3_stmt* dummy, int dummy )

FUNCTION: c-string sqlite3_column_decltype ( sqlite3_stmt* dummy, int dummy )

FUNCTION: void* sqlite3_column_decltype16 ( sqlite3_stmt* dummy, int dummy )

FUNCTION: int sqlite3_step ( sqlite3_stmt* dummy )

FUNCTION: int sqlite3_data_count ( sqlite3_stmt* pStmt )

FUNCTION: void* sqlite3_column_blob ( sqlite3_stmt* dummy, int iCol )

FUNCTION: double sqlite3_column_double ( sqlite3_stmt* dummy, int iCol )

FUNCTION: int sqlite3_column_int ( sqlite3_stmt* dummy, int iCol )

FUNCTION: longlong sqlite3_column_int64 ( sqlite3_stmt* dummy, int iCol )

FUNCTION: c-string sqlite3_column_text ( sqlite3_stmt* dummy, int iCol )

FUNCTION: void* sqlite3_column_text16 ( sqlite3_stmt* dummy, int iCol )

FUNCTION: sqlite3_value* sqlite3_column_value ( sqlite3_stmt* dummy, int iCol )

FUNCTION: int sqlite3_column_bytes ( sqlite3_stmt* dummy, int iCol )

FUNCTION: int sqlite3_column_bytes16 ( sqlite3_stmt* dummy, int iCol )

FUNCTION: int sqlite3_column_type ( sqlite3_stmt* dummy, int iCol )

FUNCTION: int sqlite3_finalize ( sqlite3_stmt* pStmt )

FUNCTION: int sqlite3_reset ( sqlite3_stmt* pStmt )

FUNCTION: int sqlite3_create_function ( sqlite3* db, char* zFunctionName, int nArg, int eTextRep, void* pApp, void* xFunc, void* xStep, void* xFinal )

FUNCTION: int sqlite3_create_function16 ( sqlite3* db, void* zFunctionName, int nArg, int eTextRep, void* pApp, void* xFunc, void* xStep, void* xFinal )

FUNCTION: int sqlite3_create_function_v2 ( sqlite3* db, char* zFunctionName, int nArg, int eTextRep, void* pApp, void* xFunc, void* xStep, void* xFinal, void* xDestroy )

FUNCTION: int sqlite3_create_window_function ( sqlite3* db, char* zFunctionName, int nArg, int eTextRep, void* pApp, void* xStep, void* xFinal, void* xValue, void* xInverse, void* xDestroy )

FUNCTION: int sqlite3_aggregate_count ( sqlite3_context* dummy )

FUNCTION: int sqlite3_expired ( sqlite3_stmt* dummy )

FUNCTION: int sqlite3_transfer_bindings ( sqlite3_stmt* dummy, sqlite3_stmt* dummy )

FUNCTION: int sqlite3_global_recover ( )

FUNCTION: void sqlite3_thread_cleanup ( )

FUNCTION: int sqlite3_memory_alarm ( void* dummy, void* dummy, sqlite3_int64 dummy )

FUNCTION: void* sqlite3_value_blob ( sqlite3_value* dummy )

FUNCTION: double sqlite3_value_double ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_int ( sqlite3_value* dummy )

FUNCTION: longlong sqlite3_value_int64 ( sqlite3_value* dummy )

FUNCTION: void* sqlite3_value_pointer ( sqlite3_value* dummy, c-string dummy )

FUNCTION: c-string sqlite3_value_text ( sqlite3_value* dummy )

FUNCTION: void* sqlite3_value_text16 ( sqlite3_value* dummy )

FUNCTION: void* sqlite3_value_text16le ( sqlite3_value* dummy )

FUNCTION: void* sqlite3_value_text16be ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_bytes ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_bytes16 ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_type ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_numeric_type ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_nochange ( sqlite3_value* dummy )

FUNCTION: int sqlite3_value_frombind ( sqlite3_value* dummy )

FUNCTION: uint sqlite3_value_subtype ( sqlite3_value* dummy )

FUNCTION: sqlite3_value* sqlite3_value_dup ( sqlite3_value* dummy )

FUNCTION: void sqlite3_value_free ( sqlite3_value* dummy )

FUNCTION: void* sqlite3_aggregate_context ( sqlite3_context* dummy, int nBytes )

FUNCTION: void* sqlite3_user_data ( sqlite3_context* dummy )

FUNCTION: sqlite3* sqlite3_context_db_handle ( sqlite3_context* dummy )

FUNCTION: void* sqlite3_get_auxdata ( sqlite3_context* dummy, int N )

FUNCTION: void sqlite3_set_auxdata ( sqlite3_context* dummy, int N, void* dummy, void* dummy )

TYPEDEF: void* sqlite3_destructor_type
FUNCTION: void sqlite3_result_blob ( sqlite3_context* dummy, void* dummy, int dummy, void* dummy )

FUNCTION: void sqlite3_result_blob64 ( sqlite3_context* dummy, void* dummy, sqlite3_uint64 dummy, void* dummy )

FUNCTION: void sqlite3_result_double ( sqlite3_context* dummy, double dummy )

FUNCTION: void sqlite3_result_error ( sqlite3_context* dummy, c-string dummy, int dummy )

FUNCTION: void sqlite3_result_error16 ( sqlite3_context* dummy, void* dummy, int dummy )

FUNCTION: void sqlite3_result_error_toobig ( sqlite3_context* dummy )

FUNCTION: void sqlite3_result_error_nomem ( sqlite3_context* dummy )

FUNCTION: void sqlite3_result_error_code ( sqlite3_context* dummy, int dummy )

FUNCTION: void sqlite3_result_int ( sqlite3_context* dummy, int dummy )

FUNCTION: void sqlite3_result_int64 ( sqlite3_context* dummy, sqlite3_int64 dummy )

FUNCTION: void sqlite3_result_null ( sqlite3_context* dummy )

FUNCTION: void sqlite3_result_text ( sqlite3_context* dummy, c-string dummy, int dummy, void* dummy )

FUNCTION: void sqlite3_result_text64 ( sqlite3_context* dummy, c-string dummy, sqlite3_uint64 dummy, void* dummy, uchar encoding )

FUNCTION: void sqlite3_result_text16 ( sqlite3_context* dummy, void* dummy, int dummy, void* dummy )

FUNCTION: void sqlite3_result_text16le ( sqlite3_context* dummy, void* dummy, int dummy, void* dummy )

FUNCTION: void sqlite3_result_text16be ( sqlite3_context* dummy, void* dummy, int dummy, void* dummy )

FUNCTION: void sqlite3_result_value ( sqlite3_context* dummy, sqlite3_value* dummy )

FUNCTION: void sqlite3_result_pointer ( sqlite3_context* dummy, void* dummy, c-string dummy, void* dummy )

FUNCTION: void sqlite3_result_zeroblob ( sqlite3_context* dummy, int n )

FUNCTION: int sqlite3_result_zeroblob64 ( sqlite3_context* dummy, sqlite3_uint64 n )

FUNCTION: void sqlite3_result_subtype ( sqlite3_context* dummy, uint dummy )

FUNCTION: int sqlite3_create_collation ( sqlite3* dummy, c-string zName, int eTextRep, void* pArg, void* xCompare )

FUNCTION: int sqlite3_create_collation_v2 ( sqlite3* dummy, c-string zName, int eTextRep, void* pArg, void* xCompare, void* xDestroy )

FUNCTION: int sqlite3_create_collation16 ( sqlite3* dummy, void* zName, int eTextRep, void* pArg, void* xCompare )

FUNCTION: int sqlite3_collation_needed ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_collation_needed16 ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_sleep ( int dummy )

C-GLOBAL: c-string sqlite3_temp_directory

C-GLOBAL: c-string sqlite3_data_directory

FUNCTION: int sqlite3_win32_set_directory ( ulong type, void* zValue )

FUNCTION: int sqlite3_win32_set_directory8 ( ulong type, c-string zValue )

FUNCTION: int sqlite3_win32_set_directory16 ( ulong type, void* zValue )

FUNCTION: int sqlite3_get_autocommit ( sqlite3* dummy )

FUNCTION: sqlite3* sqlite3_db_handle ( sqlite3_stmt* dummy )

FUNCTION: c-string sqlite3_db_filename ( sqlite3* db, c-string zDbName )

FUNCTION: int sqlite3_db_readonly ( sqlite3* db, c-string zDbName )

FUNCTION: sqlite3_stmt* sqlite3_next_stmt ( sqlite3* pDb, sqlite3_stmt* pStmt )

FUNCTION: void* sqlite3_commit_hook ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: void* sqlite3_rollback_hook ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: void* sqlite3_update_hook ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_enable_shared_cache ( int dummy )

FUNCTION: int sqlite3_release_memory ( int dummy )

FUNCTION: int sqlite3_db_release_memory ( sqlite3* dummy )

FUNCTION: longlong sqlite3_soft_heap_limit64 ( sqlite3_int64 N )

FUNCTION: void sqlite3_soft_heap_limit ( int N )

FUNCTION: int sqlite3_table_column_metadata ( sqlite3* db, c-string zDbName, c-string zTableName, c-string zColumnName, char** pzDataType, char** pzCollSeq, int* pNotNull, int* pPrimaryKey, int* pAutoinc )

FUNCTION: int sqlite3_load_extension ( sqlite3* db, c-string zFile, c-string zProc, char** pzErrMsg )

FUNCTION: int sqlite3_enable_load_extension ( sqlite3* db, int onoff )

FUNCTION: int sqlite3_auto_extension ( void* xEntryPoint )

FUNCTION: int sqlite3_cancel_auto_extension ( void* xEntryPoint )

FUNCTION: void sqlite3_reset_auto_extension ( )

C-TYPE: sqlite3_vtab
C-TYPE: sqlite3_index_info
C-TYPE: sqlite3_vtab_cursor
C-TYPE: sqlite3_module
STRUCT: sqlite3_module
  { iVersion int }
  { xCreate void* }
  { xConnect void* }
  { xBestIndex void* }
  { xDisconnect void* }
  { xDestroy void* }
  { xOpen void* }
  { xClose void* }
  { xFilter void* }
  { xNext void* }
  { xEof void* }
  { xColumn void* }
  { xRowid void* }
  { xUpdate void* }
  { xBegin void* }
  { xSync void* }
  { xCommit void* }
  { xRollback void* }
  { xFindFunction void* }
  { xRename void* }
  { xSavepoint void* }
  { xRelease void* }
  { xRollbackTo void* }
  { xShadowName void* } ;

STRUCT: sqlite3_index_constraint
  { iColumn int }
  { op uchar }
  { usable uchar }
  { iTermOffset int } ;

STRUCT: sqlite3_index_orderby
  { iColumn int }
  { desc uchar } ;

STRUCT: sqlite3_index_constraint_usage
  { argvIndex int }
  { omit uchar } ;

STRUCT: sqlite3_index_info
  { nConstraint int }
  { aConstraint sqlite3_index_constraint* }
  { nOrderBy int }
  { aOrderBy sqlite3_index_orderby* }
  { aConstraintUsage sqlite3_index_constraint_usage* }
  { idxNum int }
  { idxStr c-string }
  { needToFreeIdxStr int }
  { orderByConsumed int }
  { estimatedCost double }
  { estimatedRows sqlite3_int64 }
  { idxFlags int }
  { colUsed sqlite3_uint64 } ;

FUNCTION: int sqlite3_create_module ( sqlite3* db, c-string zName, sqlite3_module* p, void* pClientData )

FUNCTION: int sqlite3_create_module_v2 ( sqlite3* db, c-string zName, sqlite3_module* p, void* pClientData, void* xDestroy )

STRUCT: sqlite3_vtab
  { pModule sqlite3_module* }
  { nRef int }
  { zErrMsg c-string } ;

STRUCT: sqlite3_vtab_cursor
  { pVtab sqlite3_vtab* } ;

FUNCTION: int sqlite3_declare_vtab ( sqlite3* dummy, c-string zSQL )

FUNCTION: int sqlite3_overload_function ( sqlite3* dummy, c-string zFuncName, int nArg )

C-TYPE: sqlite3_blob
FUNCTION: int sqlite3_blob_open ( sqlite3* dummy, c-string zDb, c-string zTable, c-string zColumn, sqlite3_int64 iRow, int flags, sqlite3_blob** ppBlob )

FUNCTION: int sqlite3_blob_reopen ( sqlite3_blob* dummy, sqlite3_int64 dummy )

FUNCTION: int sqlite3_blob_close ( sqlite3_blob* dummy )

FUNCTION: int sqlite3_blob_bytes ( sqlite3_blob* dummy )

FUNCTION: int sqlite3_blob_read ( sqlite3_blob* dummy, void* Z, int N, int iOffset )

FUNCTION: int sqlite3_blob_write ( sqlite3_blob* dummy, void* z, int n, int iOffset )

FUNCTION: sqlite3_vfs* sqlite3_vfs_find ( c-string zVfsName )

FUNCTION: int sqlite3_vfs_register ( sqlite3_vfs* dummy, int makeDflt )

FUNCTION: int sqlite3_vfs_unregister ( sqlite3_vfs* dummy )

FUNCTION: sqlite3_mutex* sqlite3_mutex_alloc ( int dummy )

FUNCTION: void sqlite3_mutex_free ( sqlite3_mutex* dummy )

FUNCTION: void sqlite3_mutex_enter ( sqlite3_mutex* dummy )

FUNCTION: int sqlite3_mutex_try ( sqlite3_mutex* dummy )

FUNCTION: void sqlite3_mutex_leave ( sqlite3_mutex* dummy )

C-TYPE: sqlite3_mutex_methods
STRUCT: sqlite3_mutex_methods
  { xMutexInit void* }
  { xMutexEnd void* }
  { xMutexAlloc void* }
  { xMutexFree void* }
  { xMutexEnter void* }
  { xMutexTry void* }
  { xMutexLeave void* }
  { xMutexHeld void* }
  { xMutexNotheld void* } ;

FUNCTION: int sqlite3_mutex_held ( sqlite3_mutex* dummy )

FUNCTION: int sqlite3_mutex_notheld ( sqlite3_mutex* dummy )

FUNCTION: sqlite3_mutex* sqlite3_db_mutex ( sqlite3* dummy )

FUNCTION: int sqlite3_file_control ( sqlite3* dummy, c-string zDbName, int op, void* dummy )

FUNCTION: int sqlite3_test_control ( int op )

FUNCTION: int sqlite3_keyword_count ( )

FUNCTION: int sqlite3_keyword_name ( int dummy, char** dummy, int* dummy )

FUNCTION: int sqlite3_keyword_check ( c-string dummy, int dummy )

C-TYPE: sqlite3_str
FUNCTION: sqlite3_str* sqlite3_str_new ( sqlite3* dummy )

FUNCTION: c-string sqlite3_str_finish ( sqlite3_str* dummy )

FUNCTION: void sqlite3_str_appendf ( sqlite3_str* dummy, c-string zFormat )

! FUNCTION: void sqlite3_str_vappendf ( sqlite3_str* dummy, c-string zFormat, va_list dummy )

FUNCTION: void sqlite3_str_append ( sqlite3_str* dummy, c-string zIn, int N )

FUNCTION: void sqlite3_str_appendall ( sqlite3_str* dummy, c-string zIn )

FUNCTION: void sqlite3_str_appendchar ( sqlite3_str* dummy, int N, char C )

FUNCTION: void sqlite3_str_reset ( sqlite3_str* dummy )

FUNCTION: int sqlite3_str_errcode ( sqlite3_str* dummy )

FUNCTION: int sqlite3_str_length ( sqlite3_str* dummy )

FUNCTION: c-string sqlite3_str_value ( sqlite3_str* dummy )

FUNCTION: int sqlite3_status ( int op, int* pCurrent, int* pHighwater, int resetFlag )

FUNCTION: int sqlite3_status64 ( int op, sqlite3_int64* pCurrent, sqlite3_int64* pHighwater, int resetFlag )

FUNCTION: int sqlite3_db_status ( sqlite3* dummy, int op, int* pCur, int* pHiwtr, int resetFlg )

FUNCTION: int sqlite3_stmt_status ( sqlite3_stmt* dummy, int op, int resetFlg )

C-TYPE: sqlite3_pcache
C-TYPE: sqlite3_pcache_page
STRUCT: sqlite3_pcache_page
  { pBuf void* }
  { pExtra void* } ;

C-TYPE: sqlite3_pcache_methods2
STRUCT: sqlite3_pcache_methods2
  { iVersion int }
  { pArg void* }
  { xInit void* }
  { xShutdown void* }
  { xCreate void* }
  { xCachesize void* }
  { xPagecount void* }
  { xFetch void* }
  { xUnpin void* }
  { xRekey void* }
  { xTruncate void* }
  { xDestroy void* }
  { xShrink void* } ;

C-TYPE: sqlite3_pcache_methods
STRUCT: sqlite3_pcache_methods
  { pArg void* }
  { xInit void* }
  { xShutdown void* }
  { xCreate void* }
  { xCachesize void* }
  { xPagecount void* }
  { xFetch void* }
  { xUnpin void* }
  { xRekey void* }
  { xTruncate void* }
  { xDestroy void* } ;

C-TYPE: sqlite3_backup
FUNCTION: sqlite3_backup* sqlite3_backup_init ( sqlite3* pDest, c-string zDestName, sqlite3* pSource, c-string zSourceName )

FUNCTION: int sqlite3_backup_step ( sqlite3_backup* p, int nPage )

FUNCTION: int sqlite3_backup_finish ( sqlite3_backup* p )

FUNCTION: int sqlite3_backup_remaining ( sqlite3_backup* p )

FUNCTION: int sqlite3_backup_pagecount ( sqlite3_backup* p )

FUNCTION: int sqlite3_unlock_notify ( sqlite3* pBlocked, void* xNotify, void* pNotifyArg )

FUNCTION: int sqlite3_stricmp ( c-string dummy, c-string dummy )

FUNCTION: int sqlite3_strnicmp ( c-string dummy, c-string dummy, int dummy )

FUNCTION: int sqlite3_strglob ( c-string zGlob, c-string zStr )

FUNCTION: int sqlite3_strlike ( c-string zGlob, c-string zStr, uint cEsc )

FUNCTION: void sqlite3_log ( int iErrCode, c-string zFormat )

FUNCTION: void* sqlite3_wal_hook ( sqlite3* dummy, void* dummy, void* dummy )

FUNCTION: int sqlite3_wal_autocheckpoint ( sqlite3* db, int N )

FUNCTION: int sqlite3_wal_checkpoint ( sqlite3* db, c-string zDb )

FUNCTION: int sqlite3_wal_checkpoint_v2 ( sqlite3* db, c-string zDb, int eMode, int* pnLog, int* pnCkpt )

FUNCTION: int sqlite3_vtab_config ( sqlite3* dummy, int op )

FUNCTION: int sqlite3_vtab_on_conflict ( sqlite3* dummy )

FUNCTION: int sqlite3_vtab_nochange ( sqlite3_context* dummy )

FUNCTION: c-string sqlite3_vtab_collation ( sqlite3_index_info* dummy, int dummy )

FUNCTION: int sqlite3_stmt_scanstatus ( sqlite3_stmt* pStmt, int idx, int iScanStatusOp, void* pOut )

FUNCTION: void sqlite3_stmt_scanstatus_reset ( sqlite3_stmt* dummy )

FUNCTION: int sqlite3_db_cacheflush ( sqlite3* dummy )

FUNCTION: int sqlite3_system_errno ( sqlite3* dummy )

STRUCT: sqlite3_snapshot
  { hidden uchar[48] } ;

FUNCTION: int sqlite3_snapshot_get ( sqlite3* db, c-string zSchema, sqlite3_snapshot** ppSnapshot )

FUNCTION: int sqlite3_snapshot_open ( sqlite3* db, c-string zSchema, sqlite3_snapshot* pSnapshot )

FUNCTION: void sqlite3_snapshot_free ( sqlite3_snapshot* dummy )

FUNCTION: int sqlite3_snapshot_cmp ( sqlite3_snapshot* p1, sqlite3_snapshot* p2 )

FUNCTION: int sqlite3_snapshot_recover ( sqlite3* db, c-string zDb )

FUNCTION: c-string sqlite3_serialize ( sqlite3* db, c-string zSchema, sqlite3_int64* piSize, uint mFlags )

FUNCTION: int sqlite3_deserialize ( sqlite3* db, c-string zSchema, c-string pData, sqlite3_int64 szDb, sqlite3_int64 szBuf, uint mFlags )

C-TYPE: sqlite3_rtree_geometry
C-TYPE: sqlite3_rtree_query_info
TYPEDEF: double sqlite3_rtree_dbl
FUNCTION: int sqlite3_rtree_geometry_callback ( sqlite3* db, c-string zGeom, void* xGeom, void* pContext )

STRUCT: sqlite3_rtree_geometry
  { pContext void* }
  { nParam int }
  { aParam sqlite3_rtree_dbl* }
  { pUser void* }
  { xDelUser void* } ;

FUNCTION: int sqlite3_rtree_query_callback ( sqlite3* db, c-string zQueryFunc, void* xQueryFunc, void* pContext, void* xDestructor )

STRUCT: sqlite3_rtree_query_info
  { pContext void* }
  { nParam int }
  { aParam sqlite3_rtree_dbl* }
  { pUser void* }
  { xDelUser void* }
  { aCoord sqlite3_rtree_dbl* }
  { anQueue uint* }
  { nCoord int }
  { iLevel int }
  { mxLevel int }
  { iRowid sqlite3_int64 }
  { rParentScore sqlite3_rtree_dbl }
  { eParentWithin int }
  { eWithin int }
  { rScore sqlite3_rtree_dbl }
  { apSqlParam sqlite3_value** } ;

C-TYPE: Fts5ExtensionApi
C-TYPE: Fts5Context
C-TYPE: Fts5PhraseIter
TYPEDEF: void* fts5_extension_function
STRUCT: Fts5PhraseIter
  { a c-string }
  { b c-string } ;

STRUCT: Fts5ExtensionApi
  { iVersion int }
  { xUserData void* }
  { xColumnCount void* }
  { xRowCount void* }
  { xColumnTotalSize void* }
  { xTokenize void* }
  { xPhraseCount void* }
  { xPhraseSize void* }
  { xInstCount void* }
  { xInst void* }
  { xRowid void* }
  { xColumnText void* }
  { xColumnSize void* }
  { xQueryPhrase void* }
  { xSetAuxdata void* }
  { xGetAuxdata void* }
  { xPhraseFirst void* }
  { xPhraseNext void* }
  { xPhraseFirstColumn void* }
  { xPhraseNextColumn void* } ;

C-TYPE: Fts5Tokenizer
C-TYPE: fts5_tokenizer
STRUCT: fts5_tokenizer
  { xCreate void* }
  { xDelete void* }
  { xTokenize void* } ;

C-TYPE: fts5_api
STRUCT: fts5_api
  { iVersion int }
  { xCreateTokenizer void* }
  { xFindTokenizer void* }
  { xCreateFunction void* } ;
