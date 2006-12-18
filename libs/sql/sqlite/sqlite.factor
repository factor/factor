! Copyright (C) 2005 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! An interface to the sqlite database. Tested against sqlite v3.0.8.
! Remeber to pass the following to factor:
!  -libraries:sqlite=libsqlite3.so
!
! Not all functions have been wrapped yet. Only those directly involving
! executing SQL calls and obtaining results.
!
IN: sqlite
USING: alien compiler errors generic libsqlite kernel math namespaces
prettyprint sequences sql strings sql:utils ;

TUPLE: sqlite-error n message ;

! High level sqlite routines
: sqlite-check-result ( result -- )
  #! Check the result from a sqlite call is ok. If it is
  #! return, otherwise throw an error.
  dup SQLITE_OK = [
    drop 
  ] [
    dup sqlite-error-messages nth <sqlite-error> throw
  ] if ;

: sqlite-open ( filename -- db )
  #! Open the database referenced by the filename and return
  #! a handle to that database. An error is thrown if the database
  #! failed to open.
  "void*" <c-object> [ sqlite3_open sqlite-check-result ] keep *void* ;

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
  dup length "void*" <c-object> "void*" <c-object>
  [ sqlite3_prepare sqlite-check-result ] 2keep
  drop *void* ;

: sqlite-bind-text ( statement index text -- )
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

: column-text ( statement index -- string )
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

DEFER: (sqlite-map)

: (sqlite-map) ( statement quot seq -- )    
  pick sqlite3_step step-complete? [ 
    2nip
  ] [
    >r 2dup call r> curry (sqlite-map)
  ] if ; 

: sqlite-map ( statement quot -- seq )
  [ ] (sqlite-map) ;

: with-sqlite ( path quot -- )
    [
        >r sqlite-open db set r>
        [ db get sqlite-close ] cleanup
    ] with-scope ;

: bind-for-sql ( statement alist -- )
    [
        first2 >r field>sqlite-bind-name r>
        obj>string/f sqlite-bind-text-by-name
    ] each-with ;

: bind-for-insert ( statement tuple -- )
    tuple>insert-alist dupd dupd bind-for-sql ;

: bind-for-update ( statement tuple -- )
    tuple>update-alist dupd dupd dupd bind-for-sql ;

: bind-for-delete ( statement tuple -- )
    tuple>delete-alist dupd dupd bind-for-sql ;

: bind-for-select ( statement tuple -- )
    tuple>select-alist dupd dupd bind-for-sql ;

: restore-tuple ( statement tuple -- tuple )
    break
    clone dup dup full-tuple>fields
    [
        2drop
        ! over 1+ >r
        ! db-field-slot >r
        ! pick swap column-text
        ! over r> set-slot r>
    ] each-with
    ! drop make-persistent swap 0 column-text swap
    ! [ set-persistent-key ] keep
    ;

