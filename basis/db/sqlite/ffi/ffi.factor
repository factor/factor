! Copyright (C) 2005 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! An interface to the sqlite database. Tested against sqlite v3.1.3.
! Not all functions have been wrapped.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: db.sqlite.ffi

<< "sqlite" {
    { [ os windows? ] [ "sqlite3.dll" ] }
    { [ os macosx? ] [ "libsqlite3.dylib" ] }
    { [ os unix? ] [ "libsqlite3.so" ] }
} cond cdecl add-library >>

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
CONSTANT: SQLITE_STATIC      0
CONSTANT: SQLITE_TRANSIENT   -1

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

C-TYPE: sqlite3
C-TYPE: sqlite3_stmt
C-TYPE: sqlite3_value
C-TYPE: sqlite3_context
C-TYPE: sqlite3_file
TYPEDEF: longlong sqlite3_int64
TYPEDEF: ulonglong sqlite3_uint64

LIBRARY: sqlite

! FUNCTION: char sqlite3_version[]
FUNCTION: c-string sqlite3_libversion ( )
FUNCTION: c-string sqlite3_sourceid ( )
FUNCTION: int sqlite3_libversion_number ( )
FUNCTION: int sqlite3_compileoption_used ( char* zOptName )
FUNCTION: c-string sqlite3_compileoption_get ( int N )
FUNCTION: int sqlite3_threadsafe ( )

FUNCTION: int sqlite3_close ( sqlite3* pDb )
FUNCTION: int sqlite3_close_v2 ( sqlite3* pDb )

FUNCTION: int sqlite3_exec (
  sqlite3* pDb,
  char* sql,
  void* callback,
  void* arg,
  char** errmsg
)

FUNCTION: int sqlite3_initialize ( )
FUNCTION: int sqlite3_shutdown ( )
FUNCTION: int sqlite3_os_init ( )
FUNCTION: int sqlite3_os_end ( )

FUNCTION: int sqlite3_extended_result_codes ( sqlite3* pDb, int onoff )
FUNCTION: sqlite3_uint64 sqlite3_last_insert_rowid ( sqlite3* pDb )
FUNCTION: sqlite3_uint64 sqlite3_set_last_insert_rowid ( sqlite3* pDb, sqlite3_int64 n )
FUNCTION: int sqlite3_changes ( sqlite3* pDb )
FUNCTION: int sqlite3_total_changes ( sqlite3* pDb )
FUNCTION: void sqlite3_interrupt ( sqlite3* pDb )

FUNCTION: int sqlite3_complete ( c-string sql )
FUNCTION: int sqlite3_complete16 ( void *sql )

FUNCTION: void *sqlite3_malloc ( int i )
FUNCTION: void *sqlite3_malloc64 ( sqlite3_uint64 u )
FUNCTION: void *sqlite3_realloc ( void* ptr, int i )
FUNCTION: void *sqlite3_realloc64 ( void* ptr, sqlite3_uint64 u )
FUNCTION: void sqlite3_free ( void* ptr )
FUNCTION: sqlite3_uint64 sqlite3_msize ( void* ptr )

FUNCTION: sqlite3_int64 sqlite3_memory_used ( )
FUNCTION: sqlite3_int64 sqlite3_memory_highwater ( int resetFlag )

FUNCTION: void sqlite3_randomness ( int N, void *P )

FUNCTION: int sqlite3_set_authorizer (
  sqlite3* pDb,
  void* cb, ! int (*xAuth)(void*,int,const char*,const char*,const char*,const char*),
  void* pUserData
)

FUNCTION: int sqlite3_trace_v2 (
  sqlite3* pDb,
  uint uMask,
  void* cb, ! int(*xCallback)(unsigned,void*,void*,void*),
  void* pCtx
)

FUNCTION: void sqlite3_progress_handler ( sqlite3* pDb, int arg1, void* cb, void* arg2 )

FUNCTION: int sqlite3_open (
  c-string filename,      ! Database filename (UTF-8)
  sqlite3** ppDb          ! OUT: SQLite db handle
)
FUNCTION: int sqlite3_open16 (
  c-string filename,      ! Database filename (UTF-16)
  sqlite3** ppDb          ! OUT: SQLite db handle
)
FUNCTION: int sqlite3_open_v2 (
  c-string filename,      ! Database filename (UTF-8)
  sqlite3** ppDb,         ! OUT: SQLite db handle
  int flags,              ! Flags
  c-string zVfs           ! Name of VFS module to use
)

FUNCTION: c-string sqlite3_uri_parameter ( c-string zFilename, c-string zParam )
FUNCTION: int sqlite3_uri_boolean ( c-string zFile, c-string zParam, int bDefault )
FUNCTION: sqlite3_int64 sqlite3_uri_int64 ( c-string str1, c-string str2, sqlite3_int64 i )
FUNCTION: c-string sqlite3_uri_key ( c-string zFilename, int N )

FUNCTION: c-string sqlite3_filename_database ( c-string str )
FUNCTION: c-string sqlite3_filename_journal ( c-string str )
FUNCTION: c-string sqlite3_filename_wal ( c-string str )

FUNCTION: sqlite3_file* sqlite3_database_file_object ( c-string str )

FUNCTION: char* sqlite3_create_filename (
  c-string zDatabase,
  c-string zJournal,
  c-string zWal,
  int nParam,
  c-string *azParam
)
FUNCTION: void sqlite3_free_filename ( c-string name )

FUNCTION: int sqlite3_errcode ( sqlite3 *db )
FUNCTION: int sqlite3_extended_errcode ( sqlite3 *db )
FUNCTION: c-string sqlite3_errmsg ( sqlite3* pDb )
FUNCTION: void *sqlite3_errmsg16 ( sqlite3* pDb )
FUNCTION: c-string sqlite3_errstr ( int N )

FUNCTION: int sqlite3_limit ( sqlite3* pDb, int id, int newVal )

! FUNCTION: int sqlite3_prepare ( sqlite3* pDb, c-string zSql, int nBytes, void* ppStmt, void* pzTail )
! FUNCTION: int sqlite3_prepare_v2 ( sqlite3* pDb, c-string zSql, int nBytes, void* ppStmt, void* pzTail )

FUNCTION: int sqlite3_prepare (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-8 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  char** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: int sqlite3_prepare_v2 (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-8 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  char** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: int sqlite3_prepare_v3 (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-8 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  uint prepFlags,         ! Zero or more SQLITE_PREPARE_ flags
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  char** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: int sqlite3_prepare16 (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-16 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  void** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: int sqlite3_prepare16_v2 (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-16 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  void** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: int sqlite3_prepare16_v3 (
  sqlite3* db,            ! Database handle
  c-string zSql,          ! SQL statement, UTF-16 encoded
  int nByte,              ! Maximum length of zSql in bytes.
  uint prepFlags,         ! Zero or more SQLITE_PREPARE_ flags
  sqlite3_stmt** ppStmt,  ! OUT: Statement handle
  void** pzTail           ! OUT: Pointer to unused portion of zSql
)

FUNCTION: char *sqlite3_sql ( sqlite3_stmt *pStmt )
FUNCTION: char *sqlite3_expanded_sql ( sqlite3_stmt *pStmt )
FUNCTION: char *sqlite3_normalized_sql ( sqlite3_stmt *pStmt )

FUNCTION: int sqlite3_stmt_readonly ( sqlite3_stmt *pStmt )
FUNCTION: int sqlite3_stmt_isexplain ( sqlite3_stmt *pStmt )
FUNCTION: int sqlite3_stmt_busy ( sqlite3_stmt *pStmt )


FUNCTION: int sqlite3_bind_parameter_count ( sqlite3_stmt* pStmt )
FUNCTION: char* sqlite3_bind_parameter_name ( sqlite3_stmt* pStmt, int N )
FUNCTION: int sqlite3_bind_parameter_index ( sqlite3_stmt* pStmt, c-string zName )
FUNCTION: int sqlite3_clear_bindings ( sqlite3_stmt* pStmt )
FUNCTION: int sqlite3_column_count ( sqlite3_stmt* pStmt )
FUNCTION: char* sqlite3_column_name ( sqlite3_stmt* pStmt, int N )
FUNCTION: void* sqlite3_column_name16 ( sqlite3_stmt* pStmt, int N )
FUNCTION: char* sqlite3_column_database_name ( sqlite3_stmt* pStmt, int N )
FUNCTION: void* sqlite3_column_database_name16 ( sqlite3_stmt* pStmt, int N )
FUNCTION: char* sqlite3_column_table_name ( sqlite3_stmt* pStmt, int N )
FUNCTION: void* sqlite3_column_table_name16 ( sqlite3_stmt* pStmt, int N )
FUNCTION: char* sqlite3_column_origin_name ( sqlite3_stmt* pStmt, int N )
FUNCTION: void* sqlite3_column_origin_name16 ( sqlite3_stmt* pStmt, int N )

FUNCTION: c-string sqlite3_column_decltype ( sqlite3_stmt* pStmt, int col )
FUNCTION: void* sqlite3_column_decltype16 ( sqlite3_stmt* pStmt, int col )

FUNCTION: int sqlite3_step ( sqlite3_stmt* pStmt )

FUNCTION: void* sqlite3_column_blob ( sqlite3_stmt* pStmt, int col )
FUNCTION: double sqlite3_column_double ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_int ( sqlite3_stmt* pStmt, int col )
FUNCTION: sqlite3_int64 sqlite3_column_int64 ( sqlite3_stmt* pStmt, int col )
! Bind the same function as above, but for unsigned 64bit integers
FUNCTION-ALIAS: sqlite3_column_uint64
    sqlite3_uint64 sqlite3_column_int64 ( sqlite3_stmt* pStmt, int col )
FUNCTION: c-string sqlite3_column_text ( sqlite3_stmt* pStmt, int col )
FUNCTION: c-string sqlite3_column_text16 ( sqlite3_stmt* pStmt, int col )
FUNCTION: sqlite3_value* sqlite3_column_value ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_bytes ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_bytes16 ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_type ( sqlite3_stmt* pStmt, int col )

FUNCTION: int sqlite3_finalize ( sqlite3_stmt* pStmt )
FUNCTION: int sqlite3_reset ( sqlite3_stmt* pStmt )

FUNCTION: void* sqlite3_value_blob ( sqlite3_value* value )
FUNCTION: double sqlite3_value_double ( sqlite3_value* value )
FUNCTION: int sqlite3_value_int ( sqlite3_value* value )
FUNCTION: sqlite3_int64 sqlite3_value_int64 ( sqlite3_value* value )
FUNCTION: void* sqlite3_value_pointer ( sqlite3_value* value, char* value )
FUNCTION: uchar* sqlite3_value_text ( sqlite3_value* value )
FUNCTION: void* sqlite3_value_text16 ( sqlite3_value* value )
FUNCTION: void* sqlite3_value_text16le ( sqlite3_value* value )
FUNCTION: void* sqlite3_value_text16be ( sqlite3_value* value )
FUNCTION: int sqlite3_value_bytes ( sqlite3_value* value )
FUNCTION: int sqlite3_value_bytes16 ( sqlite3_value* value )
FUNCTION: int sqlite3_value_type ( sqlite3_value* value )
FUNCTION: int sqlite3_value_numeric_type ( sqlite3_value* value )
FUNCTION: int sqlite3_value_nochange ( sqlite3_value* value )
FUNCTION: int sqlite3_value_frombind ( sqlite3_value* value )

FUNCTION: uint sqlite3_value_subtype ( sqlite3_value* value )
FUNCTION: sqlite3_value *sqlite3_value_dup ( sqlite3_value* value )
FUNCTION: void sqlite3_value_free ( sqlite3_value* value )



FUNCTION: int sqlite3_data_count ( sqlite3_stmt *pStmt )

FUNCTION: int sqlite3_bind_blob ( sqlite3_stmt* pStmt, int index, void* ptr, int len, int destructor )
FUNCTION: int sqlite3_bind_double ( sqlite3_stmt* pStmt, int index, double x )
FUNCTION: int sqlite3_bind_int ( sqlite3_stmt* pStmt, int index, int n )
FUNCTION: int sqlite3_bind_int64 ( sqlite3_stmt* pStmt, int index, sqlite3_int64 n )
! Bind the same function as above, but for unsigned 64bit integers
FUNCTION-ALIAS: sqlite3-bind-uint64
    int sqlite3_bind_int64 ( sqlite3_stmt* pStmt, int index, sqlite3_uint64 in64 )
FUNCTION: int sqlite3_bind_null ( sqlite3_stmt* pStmt, int n )
FUNCTION: int sqlite3_bind_text ( sqlite3_stmt* pStmt, int index, c-string text, int len, int destructor )


FUNCTION: void* sqlite3_aggregate_context ( sqlite3_context* context, int nBytes )
FUNCTION: void* sqlite3_user_data ( sqlite3_context* context )
FUNCTION: sqlite3 *sqlite3_context_db_handle ( sqlite3_context* context )

FUNCTION: void *sqlite3_get_auxdata ( sqlite3_context* context, int N )
FUNCTION: void sqlite3_set_auxdata ( sqlite3_context* context, int N, void* arg, void* arg2 )

FUNCTION: void sqlite3_result_blob ( sqlite3_context* context, void* arg, int arg2, void* cb )
FUNCTION: void sqlite3_result_blob64 ( sqlite3_context* context, void* arg1, sqlite3_uint64 arg2, void* cb )
FUNCTION: void sqlite3_result_double ( sqlite3_context* context, double d )
FUNCTION: void sqlite3_result_error ( sqlite3_context* context, char* arg1, int arg2 )
FUNCTION: void sqlite3_result_error16 ( sqlite3_context* context, void* arg1, int arg2 )
FUNCTION: void sqlite3_result_error_toobig ( sqlite3_context* context )
FUNCTION: void sqlite3_result_error_nomem ( sqlite3_context* context )
FUNCTION: void sqlite3_result_error_code ( sqlite3_context* context, int i )
FUNCTION: void sqlite3_result_int ( sqlite3_context* context, int i )
FUNCTION: void sqlite3_result_int64 ( sqlite3_context* context, sqlite3_int64 i )
FUNCTION: void sqlite3_result_null ( sqlite3_context* context )
FUNCTION: void sqlite3_result_text ( sqlite3_context* context, char* c, int i, void* cb )
FUNCTION: void sqlite3_result_text64 ( sqlite3_context* context, char* c, sqlite3_uint64 ui, void* v, uchar encoding )
FUNCTION: void sqlite3_result_text16 ( sqlite3_context* context, void* arg, int arg2, void* arg3 )
FUNCTION: void sqlite3_result_text16le ( sqlite3_context* context, void* arg1, int arg2, void* arg3 )
FUNCTION: void sqlite3_result_text16be ( sqlite3_context* context, void* arg1, int arg2, void* arg3 )
FUNCTION: void sqlite3_result_value ( sqlite3_context* context, sqlite3_value* value )
FUNCTION: void sqlite3_result_pointer ( sqlite3_context* context, void* arg1, char* arg2, void* ptr )
FUNCTION: void sqlite3_result_zeroblob ( sqlite3_context* context, int n )
FUNCTION: int sqlite3_result_zeroblob64 ( sqlite3_context* context, sqlite3_uint64 n )

FUNCTION: void sqlite3_result_subtype ( sqlite3_context* context, uint u )

FUNCTION: int sqlite3_create_collation (
  sqlite3* pDb,
  c-string zName,
  int eTextRep,
  void* pArg,
  void* cb ! int(*xCompare)(void*,int,const void*,int,const void*)
)
FUNCTION: int sqlite3_create_collation_v2 (
  sqlite3* pDb,
  c-string zName,
  int eTextRep,
  void *pArg,
  void* cb1, ! int(*xCompare)(void*,int,const void*,int,const void*),
  void* cb2, ! void(*xDestroy)(void*)
)
FUNCTION: int sqlite3_create_collation16 (
  sqlite3* pDb,
  void *zName,
  int eTextRep,
  void* pArg,
  void* cb ! int(*xCompare)(void*,int,const void*,int,const void*)
)

FUNCTION: int sqlite3_collation_needed (
  sqlite3* pDb,
  void* ptr,
  void* cb ! void(*)(void*,sqlite3*,int eTextRep,const char*)
)
FUNCTION: int sqlite3_collation_needed16 (
  sqlite3* pDb,
  void* ptr,
  void* cb ! void(*)(void*,sqlite3*,int eTextRep,const void*)
)

FUNCTION: int sqlite3_sleep ( int n )

C-GLOBAL: c-string sqlite3_temp_directory
C-GLOBAL: c-string sqlite3_data_directory

FUNCTION: int sqlite3_win32_set_directory (
  ulong type,         ! Identifier for directory being set or reset
  void* zValue        ! New value for directory being set or reset
)
FUNCTION: int sqlite3_win32_set_directory8 ( ulong type, c-string zValue )
FUNCTION: int sqlite3_win32_set_directory16 ( ulong type, c-string zValue )

CONSTANT: SQLITE_WIN32_DATA_DIRECTORY_TYPE  1
CONSTANT: SQLITE_WIN32_TEMP_DIRECTORY_TYPE  2

FUNCTION: int sqlite3_get_autocommit ( sqlite3* pDb )
FUNCTION: sqlite3* sqlite3_db_handle ( sqlite3_stmt* pStmt )

FUNCTION: c-string sqlite3_db_filename ( sqlite3* db, c-string zDbName )
FUNCTION: int sqlite3_db_readonly ( sqlite3* db, c-string zDbName )

