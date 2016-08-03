! Copyright (C) 2005 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
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
CONSTANT: SQLITE_OK           0 ! Successful result
CONSTANT: SQLITE_ERROR        1 ! SQL error or missing database
CONSTANT: SQLITE_INTERNAL     2 ! An internal logic error in SQLite
CONSTANT: SQLITE_PERM         3 ! Access permission denied
CONSTANT: SQLITE_ABORT        4 ! Callback routine requested an abort
CONSTANT: SQLITE_BUSY         5 ! The database file is locked
CONSTANT: SQLITE_LOCKED       6 ! A table in the database is locked
CONSTANT: SQLITE_NOMEM        7 ! A malloc() failed
CONSTANT: SQLITE_READONLY     8 ! Attempt to write a readonly database
CONSTANT: SQLITE_INTERRUPT    9 ! Operation terminated by sqlite_interrupt()
CONSTANT: SQLITE_IOERR       10 ! Some kind of disk I/O error occurred
CONSTANT: SQLITE_CORRUPT     11 ! The database disk image is malformed
CONSTANT: SQLITE_NOTFOUND    12 ! (Internal Only) Table or record not found
CONSTANT: SQLITE_FULL        13 ! Insertion failed because database is full
CONSTANT: SQLITE_CANTOPEN    14 ! Unable to open the database file
CONSTANT: SQLITE_PROTOCOL    15 ! Database lock protocol error
CONSTANT: SQLITE_EMPTY       16 ! (Internal Only) Database table is empty
CONSTANT: SQLITE_SCHEMA      17 ! The database schema changed
CONSTANT: SQLITE_TOOBIG      18 ! Too much data for one row of a table
CONSTANT: SQLITE_CONSTRAINT  19 ! Abort due to contraint violation
CONSTANT: SQLITE_MISMATCH    20 ! Data type mismatch
CONSTANT: SQLITE_MISUSE      21 ! Library used incorrectly
CONSTANT: SQLITE_NOLFS       22 ! Uses OS features not supported on host
CONSTANT: SQLITE_AUTH        23 ! Authorization denied
CONSTANT: SQLITE_FORMAT      24 ! Auxiliary database format error
CONSTANT: SQLITE_RANGE       25 ! 2nd parameter to sqlite3_bind out of range
CONSTANT: SQLITE_NOTADB      26 ! File opened that is not a database file

: sqlite-error-messages ( -- seq ) {
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
} ;

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

C-TYPE: sqlite3
C-TYPE: sqlite3_stmt
TYPEDEF: longlong sqlite3_int64
TYPEDEF: ulonglong sqlite3_uint64

LIBRARY: sqlite
FUNCTION: int sqlite3_open ( c-string filename, void* ppDb )
FUNCTION: int sqlite3_close ( sqlite3* pDb )
FUNCTION: c-string sqlite3_errmsg ( sqlite3* pDb )
FUNCTION: int sqlite3_prepare ( sqlite3* pDb, c-string zSql, int nBytes, void* ppStmt, void* pzTail )
FUNCTION: int sqlite3_prepare_v2 ( sqlite3* pDb, c-string zSql, int nBytes, void* ppStmt, void* pzTail )
FUNCTION: int sqlite3_finalize ( sqlite3_stmt* pStmt )
FUNCTION: int sqlite3_reset ( sqlite3_stmt* pStmt )
FUNCTION: int sqlite3_step ( sqlite3_stmt* pStmt )
FUNCTION: sqlite3_uint64 sqlite3_last_insert_rowid ( sqlite3* pStmt )
FUNCTION: int sqlite3_bind_blob ( sqlite3_stmt* pStmt, int index, void* ptr, int len, int destructor )
FUNCTION: int sqlite3_bind_double ( sqlite3_stmt* pStmt, int index, double x )
FUNCTION: int sqlite3_bind_int ( sqlite3_stmt* pStmt, int index, int n )
FUNCTION: int sqlite3_bind_int64 ( sqlite3_stmt* pStmt, int index, sqlite3_int64 n )
! Bind the same function as above, but for unsigned 64bit integers
FUNCTION-ALIAS: sqlite3-bind-uint64
    int sqlite3_bind_int64 ( sqlite3_stmt* pStmt, int index, sqlite3_uint64 in64 )
FUNCTION: int sqlite3_bind_null ( sqlite3_stmt* pStmt, int n )
FUNCTION: int sqlite3_bind_text ( sqlite3_stmt* pStmt, int index, c-string text, int len, int destructor )
FUNCTION: int sqlite3_bind_parameter_index ( sqlite3_stmt* pStmt, c-string name )
FUNCTION: int sqlite3_clear_bindings ( sqlite3_stmt* pStmt )
FUNCTION: int sqlite3_column_count ( sqlite3_stmt* pStmt )
FUNCTION: void* sqlite3_column_blob ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_bytes ( sqlite3_stmt* pStmt, int col )
FUNCTION: c-string sqlite3_column_decltype ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_int ( sqlite3_stmt* pStmt, int col )
FUNCTION: sqlite3_int64 sqlite3_column_int64 ( sqlite3_stmt* pStmt, int col )
! Bind the same function as above, but for unsigned 64bit integers
FUNCTION-ALIAS: sqlite3_column_uint64
    sqlite3_uint64 sqlite3_column_int64 ( sqlite3_stmt* pStmt, int col )
FUNCTION: double sqlite3_column_double ( sqlite3_stmt* pStmt, int col )
FUNCTION: c-string sqlite3_column_name ( sqlite3_stmt* pStmt, int col )
FUNCTION: c-string sqlite3_column_text ( sqlite3_stmt* pStmt, int col )
FUNCTION: int sqlite3_column_type ( sqlite3_stmt* pStmt, int col )
