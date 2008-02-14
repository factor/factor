! Copyright (C) 2005 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! An interface to the sqlite database. Tested against sqlite v3.1.3.
! Not all functions have been wrapped.
USING: alien compiler kernel math namespaces sequences strings alien.syntax
    system combinators ;
IN: db.sqlite.ffi

<< "sqlite" {
        { [ winnt? ]  [ "sqlite3.dll" ] }
        { [ macosx? ] [ "/usr/lib/libsqlite3.dylib" ] }
        { [ unix? ]  [ "libsqlite3.so" ] }
    } cond "cdecl" add-library >>

! Return values from sqlite functions
: SQLITE_OK           0   ; inline ! Successful result
: SQLITE_ERROR        1   ; inline ! SQL error or missing database
: SQLITE_INTERNAL     2   ; inline ! An internal logic error in SQLite 
: SQLITE_PERM         3   ; inline ! Access permission denied 
: SQLITE_ABORT        4   ; inline ! Callback routine requested an abort 
: SQLITE_BUSY         5   ; inline ! The database file is locked 
: SQLITE_LOCKED       6   ; inline ! A table in the database is locked 
: SQLITE_NOMEM        7   ; inline ! A malloc() failed 
: SQLITE_READONLY     8   ; inline ! Attempt to write a readonly database 
: SQLITE_INTERRUPT    9   ; inline ! Operation terminated by sqlite_interrupt() 
: SQLITE_IOERR       10   ; inline ! Some kind of disk I/O error occurred 
: SQLITE_CORRUPT     11   ; inline ! The database disk image is malformed 
: SQLITE_NOTFOUND    12   ; inline ! (Internal Only) Table or record not found 
: SQLITE_FULL        13   ; inline ! Insertion failed because database is full 
: SQLITE_CANTOPEN    14   ; inline ! Unable to open the database file 
: SQLITE_PROTOCOL    15   ; inline ! Database lock protocol error 
: SQLITE_EMPTY       16   ; inline ! (Internal Only) Database table is empty 
: SQLITE_SCHEMA      17   ; inline ! The database schema changed 
: SQLITE_TOOBIG      18   ; inline ! Too much data for one row of a table 
: SQLITE_CONSTRAINT  19   ; inline ! Abort due to contraint violation 
: SQLITE_MISMATCH    20   ; inline ! Data type mismatch 
: SQLITE_MISUSE      21   ; inline ! Library used incorrectly 
: SQLITE_NOLFS       22   ; inline ! Uses OS features not supported on host 
: SQLITE_AUTH        23   ; inline ! Authorization denied 
: SQLITE_FORMAT      24   ; inline ! Auxiliary database format error
: SQLITE_RANGE       25   ; inline ! 2nd parameter to sqlite3_bind out of range
: SQLITE_NOTADB      26   ; inline ! File opened that is not a database file

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
: SQLITE_ROW         100  ; inline
: SQLITE_DONE        101  ; inline

! Return values from the sqlite3_column_type function
: SQLITE_INTEGER     1 ; inline
: SQLITE_FLOAT       2 ; inline
: SQLITE_TEXT        3 ; inline
: SQLITE_BLOB        4 ; inline
: SQLITE_NULL        5 ; inline

! Values for the 'destructor' parameter of the 'bind' routines. 
: SQLITE_STATIC      0  ; inline
: SQLITE_TRANSIENT   -1 ; inline

: SQLITE_OPEN_READONLY         HEX: 00000001 ; inline
: SQLITE_OPEN_READWRITE        HEX: 00000002 ; inline
: SQLITE_OPEN_CREATE           HEX: 00000004 ; inline
: SQLITE_OPEN_DELETEONCLOSE    HEX: 00000008 ; inline
: SQLITE_OPEN_EXCLUSIVE        HEX: 00000010 ; inline
: SQLITE_OPEN_MAIN_DB          HEX: 00000100 ; inline
: SQLITE_OPEN_TEMP_DB          HEX: 00000200 ; inline
: SQLITE_OPEN_TRANSIENT_DB     HEX: 00000400 ; inline
: SQLITE_OPEN_MAIN_JOURNAL     HEX: 00000800 ; inline
: SQLITE_OPEN_TEMP_JOURNAL     HEX: 00001000 ; inline
: SQLITE_OPEN_SUBJOURNAL       HEX: 00002000 ; inline
: SQLITE_OPEN_MASTER_JOURNAL   HEX: 00004000 ; inline

TYPEDEF: void sqlite3
TYPEDEF: void sqlite3_stmt
TYPEDEF: longlong sqlite3_int64
TYPEDEF: ulonglong sqlite3_uint64

LIBRARY: sqlite
FUNCTION: int sqlite3_open ( char* filename, void* ppDb ) ;
FUNCTION: int sqlite3_close ( sqlite3* pDb ) ;
FUNCTION: char* sqlite3_errmsg ( sqlite3* pDb ) ;
FUNCTION: int sqlite3_prepare ( sqlite3* pDb, char* zSql, int nBytes, void* ppStmt, void* pzTail ) ;
FUNCTION: int sqlite3_finalize ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_reset ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_step ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_last_insert_rowid ( sqlite3* pStmt ) ;
FUNCTION: int sqlite3_bind_blob ( sqlite3_stmt* pStmt, int index, void* ptr, int len, int destructor ) ;
FUNCTION: int sqlite3_bind_double ( sqlite3_stmt* pStmt, int index, double x ) ;
FUNCTION: int sqlite3_bind_int ( sqlite3_stmt* pStmt, int index, int n ) ;
FUNCTION: int sqlite3_bind_int64 ( sqlite3_stmt* pStmt, int index, sqlite3_int64 n ) ;
FUNCTION: int sqlite3_bind_null ( sqlite3_stmt* pStmt, int n ) ;
FUNCTION: int sqlite3_bind_text ( sqlite3_stmt* pStmt, int index, char* text, int len, int destructor ) ;
FUNCTION: int sqlite3_bind_parameter_index ( sqlite3_stmt* pStmt, char* name ) ;
FUNCTION: int sqlite3_column_count ( sqlite3_stmt* pStmt ) ;
FUNCTION: void* sqlite3_column_blob ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: int sqlite3_column_bytes ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: char* sqlite3_column_decltype ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: int sqlite3_column_int ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: int sqlite3_column_name ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: char* sqlite3_column_text ( sqlite3_stmt* pStmt, int col ) ;
FUNCTION: int sqlite3_column_type ( sqlite3_stmt* pStmt, int col ) ;
