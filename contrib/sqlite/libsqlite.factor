! Copyright (C) 2005 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
!
! An interface to the sqlite database. Tested against sqlite v3.1.3.
! Remeber to pass the following to factor:
!  -libraries:sqlite=libsqlite3.so
!
! Not all functions have been wrapped yet. Only those directly involving
! executing SQL calls and obtaining results.
!
IN: libsqlite
USING: alien compiler errors kernel math namespaces sequences strings ;

! Return values from sqlite functions
: SQLITE_OK           0   ; ! Successful result
: SQLITE_ERROR        1   ; ! SQL error or missing database
: SQLITE_INTERNAL     2   ; ! An internal logic error in SQLite 
: SQLITE_PERM         3   ; ! Access permission denied 
: SQLITE_ABORT        4   ; ! Callback routine requested an abort 
: SQLITE_BUSY         5   ; ! The database file is locked 
: SQLITE_LOCKED       6   ; ! A table in the database is locked 
: SQLITE_NOMEM        7   ; ! A malloc() failed 
: SQLITE_READONLY     8   ; ! Attempt to write a readonly database 
: SQLITE_INTERRUPT    9   ; ! Operation terminated by sqlite_interrupt() 
: SQLITE_IOERR       10   ; ! Some kind of disk I/O error occurred 
: SQLITE_CORRUPT     11   ; ! The database disk image is malformed 
: SQLITE_NOTFOUND    12   ; ! (Internal Only) Table or record not found 
: SQLITE_FULL        13   ; ! Insertion failed because database is full 
: SQLITE_CANTOPEN    14   ; ! Unable to open the database file 
: SQLITE_PROTOCOL    15   ; ! Database lock protocol error 
: SQLITE_EMPTY       16   ; ! (Internal Only) Database table is empty 
: SQLITE_SCHEMA      17   ; ! The database schema changed 
: SQLITE_TOOBIG      18   ; ! Too much data for one row of a table 
: SQLITE_CONSTRAINT  19   ; ! Abort due to contraint violation 
: SQLITE_MISMATCH    20   ; ! Data type mismatch 
: SQLITE_MISUSE      21   ; ! Library used incorrectly 
: SQLITE_NOLFS       22   ; ! Uses OS features not supported on host 
: SQLITE_AUTH        23   ; ! Authorization denied 
: SQLITE_FORMAT      24   ; ! Auxiliary database format error
: SQLITE_RANGE       25   ; ! 2nd parameter to sqlite3_bind out of range
: SQLITE_NOTADB      26   ; ! File opened that is not a database file

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

: SQLITE_ROW         100  ; ! sqlite_step() has another row ready 
: SQLITE_DONE        101  ; ! sqlite_step() has finished executing 

! Return values from the sqlite3_column_type function
: SQLITE_INTEGER     1 ;
: SQLITE_FLOAT       2 ;
: SQLITE_TEXT        3 ;
: SQLITE_BLOB        4 ;
: SQLITE_NULL        5 ;

! Values for the 'destructor' parameter of the 'bind' routines. 
: SQLITE_STATIC      0  ;
: SQLITE_TRANSIENT   -1 ;

TYPEDEF: void sqlite3
TYPEDEF: void sqlite3_stmt

LIBRARY: sqlite
FUNCTION: int sqlite3_open ( char* filename, void* ppDb ) ;
FUNCTION: int sqlite3_close ( sqlite3* pDb ) ;
FUNCTION: int sqlite3_prepare ( sqlite3* pDb, char* zSql, int nBytes, void* ppStmt, void* pzTail ) ;
FUNCTION: int sqlite3_finalize ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_reset ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_step ( sqlite3_stmt* pStmt ) ;
FUNCTION: int sqlite3_last_insert_rowid ( sqlite3* pStmt ) ;
FUNCTION: int sqlite3_bind_blob ( sqlite3_stmt* pStmt, int index, void* ptr, int len, int destructor ) ;
FUNCTION: int sqlite3_bind_int ( sqlite3_stmt* pStmt, int index, int n ) ;
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

