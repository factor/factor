! Copyright (C) 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays assocs kernel math math.parser
namespaces sequences db.sqlite.ffi db combinators
continuations db.types ;
IN: db.sqlite.lib

: sqlite-error ( n -- * )
    sqlite-error-messages nth throw ;

: sqlite-statement-error-string ( -- str )
    db get db-handle sqlite3_errmsg ;

: sqlite-statement-error ( -- * )
    sqlite-statement-error-string throw ;

: sqlite-check-result ( n -- )
    {
        { [ dup SQLITE_OK = ] [ drop ] }
        { [ dup SQLITE_ERROR = ] [ sqlite-statement-error ] }
        { [ t ] [ sqlite-error ] }
    } cond ;

: sqlite-open ( filename -- db )
    "void*" <c-object>
    [ sqlite3_open sqlite-check-result ] keep *void* ;

: sqlite-close ( db -- )
    sqlite3_close sqlite-check-result ;

: sqlite-prepare ( db sql -- handle )
    dup length "void*" <c-object> "void*" <c-object>
    [ sqlite3_prepare sqlite-check-result ] 2keep
    drop *void* ;

: sqlite-bind-parameter-index ( handle name -- index )
    sqlite3_bind_parameter_index ;

: parameter-index ( handle name text -- handle name text )
    >r dupd sqlite-bind-parameter-index r> ;

: sqlite-bind-text ( handle index text -- )
    dup length SQLITE_TRANSIENT
    sqlite3_bind_text sqlite-check-result ;

: sqlite-bind-int ( handle i n -- )
    sqlite3_bind_int sqlite-check-result ;

: sqlite-bind-int64 ( handle i n -- )
    sqlite3_bind_int64 sqlite-check-result ;

: sqlite-bind-double ( handle i x -- )
    sqlite3_bind_double sqlite-check-result ;

: sqlite-bind-null ( handle i -- )
    sqlite3_bind_null sqlite-check-result ;

: sqlite-bind-text-by-name ( handle name text -- )
    parameter-index sqlite-bind-text ;

: sqlite-bind-int-by-name ( handle name int -- )
    parameter-index sqlite-bind-int ;

: sqlite-bind-int64-by-name ( handle name int64 -- )
    parameter-index sqlite-bind-int ;

: sqlite-bind-double-by-name ( handle name double -- )
    parameter-index sqlite-bind-double ;

: sqlite-bind-null-by-name ( handle name obj -- )
    parameter-index drop sqlite-bind-null ;

: sqlite-bind-type ( handle key value type -- )
    dup array? [ first ] when
    {
        { INTEGER [ sqlite-bind-int-by-name ] }
        { BIG_INTEGER [ sqlite-bind-int64-by-name ] }
        { TEXT [ sqlite-bind-text-by-name ] }
        { VARCHAR [ sqlite-bind-text-by-name ] }
        { DOUBLE [ sqlite-bind-double-by-name ] }
        { SERIAL [ sqlite-bind-int-by-name ] }
        ! { NULL [ sqlite-bind-null-by-name ] }
        [ no-sql-type ]
    } case ;

: sqlite-finalize ( handle -- )
    sqlite3_finalize sqlite-check-result ;

: sqlite-reset ( handle -- )
    sqlite3_reset sqlite-check-result ;

: sqlite-#columns ( query -- int )
    sqlite3_column_count ;

! TODO
: sqlite-column ( handle index -- string )
    sqlite3_column_text ;

: sqlite-column-typed ( handle index type -- obj )
    {
        { INTEGER [ sqlite3_column_int ] }
        { BIG_INTEGER [ sqlite3_column_int64 ] }
        { TEXT [ sqlite3_column_text ] }
        { DOUBLE [ sqlite3_column_double ] }
    } case ;

! TODO
: sqlite-row ( handle -- seq )
    dup sqlite-#columns [ sqlite-column ] with map ;

: sqlite-step-has-more-rows? ( step-result -- bool )
    dup SQLITE_ROW =  [
        drop t
    ] [
        dup SQLITE_DONE =
        [ drop ] [ sqlite-check-result ] if f
    ] if ;

: sqlite-next ( prepared -- ? )
    sqlite3_step sqlite-step-has-more-rows? ;
