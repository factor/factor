! Copyright (C) 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types assocs kernel math math.parser
namespaces sequences db.sqlite.ffi db combinators
continuations ;
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
    [ sqlite3_prepare_v2 sqlite-check-result ] 2keep
    drop *void* ;

: sqlite-bind-parameter-index ( handle name -- index )
    sqlite3_bind_parameter_index ;

: parameter-index ( handle name text -- handle name text )
    >r dupd sqlite-bind-parameter-index r> ;

: sqlite-bind-text ( handle index text -- )
    ! dup number? [ number>string ] when
    dup length SQLITE_TRANSIENT sqlite3_bind_text sqlite-check-result ;

: sqlite-bind-int ( handle name n -- )
    sqlite3_bind_int sqlite-check-result ;

: sqlite-bind-int64 ( handle name n -- )
    sqlite3_bind_int64 sqlite-check-result ;

: sqlite-bind-null ( handle n -- )
    sqlite3_bind_null sqlite-check-result ;

: sqlite-bind-text-by-name ( handle name text -- )
    parameter-index sqlite-bind-text ;

: sqlite-bind-int-by-name ( handle name text -- )
    parameter-index sqlite-bind-int ;

: sqlite-bind-int64-by-name ( handle name text -- )
    parameter-index sqlite-bind-int ;

: sqlite-bind-null-by-name ( handle name obj -- )
    parameter-index drop sqlite-bind-null ;

: sqlite-finalize ( handle -- )
    sqlite3_finalize sqlite-check-result ;

: sqlite-reset ( handle -- )
    sqlite3_reset sqlite-check-result ;

: sqlite-#columns ( query -- int )
    sqlite3_column_count ;

! TODO
: sqlite-column ( handle index -- string )
    sqlite3_column_text ;

! TODO
: sqlite-row ( handle -- seq )
    dup sqlite-#columns [ sqlite-column ] with map ;

: step-complete? ( step-result -- bool )
    dup SQLITE_ROW =  [
        drop f
    ] [
        dup SQLITE_DONE =
        [ drop ] [ sqlite-check-result ] if t
    ] if ;

: sqlite-next ( prepared -- ? )
    sqlite3_step step-complete? ;
