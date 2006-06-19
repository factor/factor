! Copyright (C) 2005 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
! An interface to the sqlite database. Tested against sqlite v3.0.8.
! Remeber to pass the following to factor:
!  -libraries:sqlite=libsqlite3.so
!
! Not all functions have been wrapped yet. Only those directly involving
! executing SQL calls and obtaining results.
!
IN: sqlite
USE: kernel
USE: alien
USE: errors
USE: strings
USE: namespaces
USE: sequences
USE: compiler

BEGIN-STRUCT: sqlite3
END-STRUCT

BEGIN-STRUCT: sqlite3-indirect
  FIELD: sqlite3* pointer
END-STRUCT

BEGIN-STRUCT: sqlite3-stmt
END-STRUCT

BEGIN-STRUCT: sqlite3-stmt-indirect
  FIELD: sqlite3-stmt* pointer
END-STRUCT

BEGIN-STRUCT: char*-indirect
  FIELD: char* pointer
END-STRUCT

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

: sqlite3_open ( filename sqlite3-indirect -- result )
  "int" "sqlite" "sqlite3_open" [ "char*" "sqlite3-indirect*" ] alien-invoke ; 

: sqlite3_close ( db -- )
  "int" "sqlite" "sqlite3_close" [ "sqlite3*" ] alien-invoke ; 

: sqlite3_prepare ( db sql sql-len sqlite3-stmt-indirect tail -- result )
  "int" "sqlite" "sqlite3_prepare" [ "sqlite3*" "char*" "int" "sqlite3-stmt-indirect*" "char*-indirect*" ] alien-invoke ; 

: sqlite3_finalize ( stmt -- result ) 
  "int" "sqlite" "sqlite3_finalize" [ "sqlite3-stmt*" ] alien-invoke ; 

: sqlite3_reset ( stmt -- result )
  "int" "sqlite" "sqlite3_reset" [ "sqlite3-stmt*" ] alien-invoke ; 

: sqlite3_step ( stmt -- result )
  "int" "sqlite" "sqlite3_step" [ "sqlite3-stmt*" ] alien-invoke ; 

: sqlite3_last_insert_rowid ( stmt index int -- result )
  "int" "sqlite" "sqlite3_last_insert_rowid" [ "sqlite3*" ] alien-invoke ; 

: sqlite3_bind_blob ( stmt index pointer len destructor -- result )
  "int" "sqlite" "sqlite3_bind_blob" [ "sqlite3-stmt*" "int" "void*" "int" "int" ] alien-invoke ; 

: sqlite3_bind_int ( stmt index int -- result )
  "int" "sqlite" "sqlite3_bind_int" [ "sqlite3-stmt*" "int" "int" ] alien-invoke ; 

: sqlite3_bind_null ( stmt index  -- result )
  "int" "sqlite" "sqlite3_bind_null" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_bind_text ( stmt index text len destructor -- result )
  "int" "sqlite" "sqlite3_bind_text" [ "sqlite3-stmt*" "int" "char*" "int" "int" ] alien-invoke ; 

: sqlite3_bind_parameter_index ( stmt name -- result )
  "int" "sqlite" "sqlite3_bind_parameter_index" [ "sqlite3-stmt*" "char*" ] alien-invoke ; 

: sqlite3_column_count ( stmt -- count )
  "int" "sqlite" "sqlite3_column_count" [ "sqlite3-stmt*" ] alien-invoke ; 

: sqlite3_column_blob ( stmt col -- void* )
  "void*" "sqlite" "sqlite3_column_blob" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_bytes ( stmt col -- int )
  "int" "sqlite" "sqlite3_column_bytes" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_decltype ( stmt col -- string )
  "char*" "sqlite" "sqlite3_column_decltype" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_int ( stmt col -- int )
  "int" "sqlite" "sqlite3_column_int" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_name ( stmt col -- string )
  "char*" "sqlite" "sqlite3_column_name" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_text ( stmt col -- string )
  "char*" "sqlite" "sqlite3_column_text" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

: sqlite3_column_type ( stmt col -- int )
  "int" "sqlite" "sqlite3_column_type" [ "sqlite3-stmt*" "int" ] alien-invoke ; 

! High level sqlite routines
: sqlite-check-result ( result -- )
  #! Check the result from a sqlite call is ok. If it is
  #! return, otherwise throw an error. TODO: Throw the actual
  #! error text message.
  dup SQLITE_OK = [
    drop 
  ] [
    "sqlite returned an error. See datastack for the error value." throw
  ] if ;

: sqlite-open ( filename -- db )
  #! Open the database referenced by the filename and return
  #! a handle to that database. An error is thrown if the database
  #! failed to open.
  "sqlite3-indirect" <c-object> tuck sqlite3_open sqlite-check-result sqlite3-indirect-pointer ;

: sqlite-close ( db -- )
  #! Close the given database
  sqlite3_close sqlite-check-result ;

: sqlite-last-insert-rowid ( db -- rowid )
  #! Return the rowid of the last insert
  sqlite3_last_insert_rowid ;

: sqlite-prepare ( db sql -- statement )
  #! Prepare a SQL statement. Returns the statement which
  #! can have values bound to parameters or simply executed.
  #! TODO: Support multiple statements in the SQL string.
  dup length "sqlite3-stmt-indirect" <c-object> dup >r 
  "char*-indirect" <c-object> sqlite3_prepare sqlite-check-result
  r> sqlite3-stmt-indirect-pointer ;

: sqlite-bind-text ( statement col text -- )
  #! Bind the text to the parameterized value in the statement.  
  dup length SQLITE_TRANSIENT sqlite3_bind_text sqlite-check-result ;

: sqlite-bind-parameter-index ( statement name -- index )
  sqlite3_bind_parameter_index ;

: sqlite-bind-text-by-name ( statement name text -- )
  >r dupd sqlite-bind-parameter-index r> sqlite-bind-text ;

: sqlite-finalize ( statement -- )
  #! Clean up all resources related to a statement. Once called
  #! the statement cannot be used. All statements must be finalized
  #! before closing the database.
  sqlite3_finalize sqlite-check-result ;

: sqlite-reset ( statement -- )
  #! Reset a statement so it can be called again, possibly with
  #! different parameters.
  sqlite3_reset sqlite-check-result ;

: column-count ( statement -- int )
  #! Given a prepared statement, return the number of
  #! columns in each row of the result set of that statement.
  sqlite3_column_count ;

: column-text ( statement column -- string )
  #! Return the value of the given column, indexed
  #! from zero, as a string.
  sqlite3_column_text ;

: step-complete? ( step-result -- bool )
  #! Return true if the result of a sqlite3_step is
  #! such that the iteration has completed (ie. it is
  #! SQLITE_DONE). Throw an error if an error occurs. 
  dup SQLITE_ROW =  [
    drop f
  ] [
    dup SQLITE_DONE = [
      drop t 
    ] [
      sqlite-check-result t
    ] if
  ] if ;

: sqlite-each ( statement quot -- )    
  #! Execute the SQL statement, and call the quotation for
  #! each row returned from executing the statement with the
  #! statement on the top of the stack.
  over sqlite3_step step-complete? [ 
    2drop
  ] [
    [ call ] 2keep sqlite-each
  ] if ; inline

! For comparison, here is the linrec implementation of sqlite-each
! [ drop sqlite3_step step-complete? ]
! [ 2drop ]
! [ 2dup 2slip ]
! [ ] linrec ; 

: (sqlite-map) ( statement quot seq -- )    
  pick sqlite3_step step-complete? [ 
    2nip
  ] [
    >r 2dup call r> curry (sqlite-map)
  ] if ;

: sqlite-map ( statement quot -- )
  [ ] (sqlite-map) ;
